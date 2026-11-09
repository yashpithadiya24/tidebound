class_name IslandView
extends Node2D
## The home island screen: terrain, water tint, Harbor Hall box, camera, tap info (C03).
## Why: the view only shows state. Rules live in GridModel and TideModel (02 section 3, rule 7).

const ISLAND_ID: String = "home_isle"
## Harbor Hall is 3x3 tiles (03 section 5). C04 reads this from buildings.json.
const HARBOR_SIZE_TILES: int = 3
const HUD_LAYER: int = 10
## Placeholder colors from 06 section 2. The art pass replaces them.
const WATER_TINT_COLOR: String = "#4fb3d9"
const HARBOR_COLOR: String = "#b9824f"
const SELECT_COLOR: String = "#ff9f43"
const SELECT_WIDTH: float = 6.0
const NO_TILE: Vector2i = Vector2i(-1, -1)

var grid: GridModel

var _island: IslandData
var _terrain: TileMapLayer
var _water: TileMapLayer
var _camera: IslandCamera
var _selector: Line2D
var _info_panel: TileInfoPanel
var _atlas_index: Dictionary = {}
var _tint_index: int = 0
var _tint_min: float = 0.0
var _tint_max: float = 0.0
var _selected: Vector2i = NO_TILE


func _ready() -> void:
	_island = IslandData.from_dict(Data.load_island(ISLAND_ID))
	var tile_px: int = Data.tuning_int("tile_px")
	grid = GridModel.new(_island, Data.tiles, tile_px)
	if grid.width == 0:
		Log.error("IslandView", "Island '%s' could not be loaded" % ISLAND_ID)
		return
	_tint_min = float(Data.tuning.get("water_tint_alpha_min", 0.0))
	_tint_max = float(Data.tuning.get("water_tint_alpha_max", 0.0))

	var tile_set: TileSet = _build_tile_set(tile_px)
	_terrain = _make_layer(tile_set)
	_water = _make_layer(tile_set)
	_draw_terrain()
	_add_harbor_box()
	_add_selector()
	_add_camera()
	_add_hud()

	EventBus.tide_phase_changed.connect(_on_tide_changed)
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_update_tint)
	add_child(timer)
	_on_tide_changed(Tide.current_phase(), Tide.current_index())


## Builds one TileSet from colored squares: one per tile type, then the water tint.
func _build_tile_set(tile_px: int) -> TileSet:
	var colors: Array[Color] = []
	for type_name: String in Data.tiles:
		var tile_def: Dictionary = Data.tiles[type_name]
		_atlas_index[type_name] = colors.size()
		colors.append(Color.html(str(tile_def.get("color", "#ff00ff"))))
	_tint_index = colors.size()
	colors.append(Color.html(WATER_TINT_COLOR))

	var image: Image = Image.create(tile_px * colors.size(), tile_px, false, Image.FORMAT_RGBA8)
	for i: int in range(colors.size()):
		image.fill_rect(Rect2i(i * tile_px, 0, tile_px, tile_px), colors[i])
	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(tile_px, tile_px)
	for i: int in range(colors.size()):
		source.create_tile(Vector2i(i, 0))
	var tile_set: TileSet = TileSet.new()
	tile_set.tile_size = Vector2i(tile_px, tile_px)
	tile_set.add_source(source, 0)
	return tile_set


func _make_layer(tile_set: TileSet) -> TileMapLayer:
	var layer: TileMapLayer = TileMapLayer.new()
	layer.tile_set = tile_set
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(layer)
	return layer


func _draw_terrain() -> void:
	for y: int in range(grid.height):
		for x: int in range(grid.width):
			var atlas_x: int = int(_atlas_index.get(grid.get_tile_type(x, y), -1))
			if atlas_x >= 0:
				_terrain.set_cell(Vector2i(x, y), 0, Vector2i(atlas_x, 0))


## Wet tiles get the tint tile. Dry tiles get none. Uses the discrete water index (D-027).
func _update_water(index: int) -> void:
	for y: int in range(grid.height):
		for x: int in range(grid.width):
			var cell: Vector2i = Vector2i(x, y)
			if grid.is_underwater_at(x, y, index):
				_water.set_cell(cell, 0, Vector2i(_tint_index, 0))
			else:
				_water.erase_cell(cell)


## Tint strength follows the smooth visual level (R-TIDE-8).
func _update_tint() -> void:
	var level: float = Tide.model.visual_level(Clock.now())
	_water.modulate.a = lerpf(_tint_min, _tint_max, level)


func _add_harbor_box() -> void:
	var size_px: float = float(HARBOR_SIZE_TILES * grid.tile_px)
	var box: ColorRect = ColorRect.new()
	box.color = Color.html(HARBOR_COLOR)
	box.size = Vector2(size_px, size_px)
	box.position = grid.tile_to_world(_island.harbor_x, _island.harbor_y)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	var label: Label = Label.new()
	label.text = "Harbor Hall"
	label.size = box.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(label)


func _add_selector() -> void:
	var s: float = float(grid.tile_px)
	_selector = Line2D.new()
	_selector.points = PackedVector2Array([
		Vector2(0, 0), Vector2(s, 0), Vector2(s, s), Vector2(0, s), Vector2(0, 0)
	])
	_selector.width = SELECT_WIDTH
	_selector.default_color = Color.html(SELECT_COLOR)
	_selector.visible = false
	add_child(_selector)


func _add_camera() -> void:
	_camera = IslandCamera.new()
	add_child(_camera)
	var margin_px: float = float(Data.tuning_int("camera_margin_tiles") * grid.tile_px)
	var bounds: Rect2 = CameraMath.island_bounds(grid.pixel_size(), margin_px)
	_camera.setup(
		bounds,
		grid.pixel_size(),
		float(Data.tuning.get("camera_zoom_min", 1.0)),
		float(Data.tuning.get("camera_zoom_max", 1.0)),
		float(Data.tuning_int("tap_max_move_px"))
	)
	_camera.tapped.connect(_on_tapped)


func _add_hud() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = HUD_LAYER
	add_child(layer)
	layer.add_child(TideWidget.new())
	_info_panel = TileInfoPanel.new()
	layer.add_child(_info_panel)


func _on_tide_changed(_phase: String, index: int) -> void:
	_update_water(index)
	_update_tint()
	_refresh_selection()


## A tap on the same tile or outside the island closes the info.
func _on_tapped(world_pos: Vector2) -> void:
	var tile: Vector2i = grid.world_to_tile(world_pos)
	if not grid.in_bounds(tile.x, tile.y) or tile == _selected:
		_selected = NO_TILE
	else:
		_selected = tile
	_refresh_selection()


func _refresh_selection() -> void:
	if _selected == NO_TILE:
		_selector.visible = false
		_info_panel.hide_tile()
		return
	var index: int = Tide.current_index()
	_selector.position = grid.tile_to_world(_selected.x, _selected.y)
	_selector.visible = true
	_info_panel.show_tile(
		_selected.x,
		_selected.y,
		grid.get_tile_type(_selected.x, _selected.y),
		grid.get_elevation(_selected.x, _selected.y),
		index,
		grid.is_dry_at(_selected.x, _selected.y, index)
	)
