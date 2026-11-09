class_name GridModel
extends RefCounted
## Stores the elevation of every tile of one island (02 section 6).
## Why: pure logic with no nodes. The view and the tests both use it.

## Returned by get_elevation() for a cell outside the grid. Check in_bounds() first.
const OUTSIDE: int = -99
## Used when a tile type is not in tiles.json (same as open sea).
const FALLBACK_ELEVATION: int = -1

var width: int = 0
var height: int = 0
var tile_px: int = 1

var _types: PackedStringArray = PackedStringArray()
var _elevations: PackedInt32Array = PackedInt32Array()


## island: parsed map. tiles: Data.tiles. tile_size_px: tuning tile_px.
## An invalid island gives an empty grid (width 0, height 0).
func _init(island: IslandData, tiles: Dictionary, tile_size_px: int) -> void:
	tile_px = maxi(1, tile_size_px)
	if not island.valid:
		return
	width = island.width
	height = island.height
	_types = island.tile_types
	_elevations.resize(width * height)
	var warned: Dictionary = {}
	for i: int in range(_types.size()):
		var type_name: String = _types[i]
		if tiles.has(type_name):
			var tile_def: Dictionary = tiles[type_name]
			_elevations[i] = int(tile_def.get("elevation", FALLBACK_ELEVATION))
		else:
			_elevations[i] = FALLBACK_ELEVATION
			if not warned.has(type_name):
				warned[type_name] = true
				Log.warn("GridModel", "Tile type '%s' is not in tiles.json" % type_name)


## True when (x, y) is inside the grid.
func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


## Tile type name such as "REEF". Empty string outside the grid.
func get_tile_type(x: int, y: int) -> String:
	if not in_bounds(x, y):
		return ""
	return _types[y * width + x]


## Elevation of a tile. OUTSIDE if the cell is not in the grid.
func get_elevation(x: int, y: int) -> int:
	if not in_bounds(x, y):
		return OUTSIDE
	return _elevations[y * width + x]


## True when the tile is dry at this water index (R-TIDE-5). False outside the grid.
func is_dry_at(x: int, y: int, water_index: int) -> bool:
	if not in_bounds(x, y):
		return false
	return TideModel.is_dry(get_elevation(x, y), water_index)


## True when the tile is underwater at this water index (R-TIDE-5). False outside the grid.
func is_underwater_at(x: int, y: int, water_index: int) -> bool:
	if not in_bounds(x, y):
		return false
	return TideModel.is_underwater(get_elevation(x, y), water_index)


## Tile under a world position (pixels). The result may be outside the grid.
func world_to_tile(pos: Vector2) -> Vector2i:
	var size: float = float(tile_px)
	return Vector2i(floori(pos.x / size), floori(pos.y / size))


## Top-left corner of a tile in world pixels.
func tile_to_world(x: int, y: int) -> Vector2:
	return Vector2(float(x * tile_px), float(y * tile_px))


## Size of the whole island in world pixels.
func pixel_size() -> Vector2:
	return Vector2(float(width * tile_px), float(height * tile_px))
