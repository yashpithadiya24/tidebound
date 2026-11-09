class_name TileInfoPanel
extends Control
## Info box at the bottom (thumb zone) for the tapped tile (C03).
## Hidden until a tile is tapped. It only shows what the model says.

const PANEL_WIDTH: float = 960.0
const PANEL_HEIGHT: float = 220.0
const BOTTOM_MARGIN: float = 40.0
const FONT_SIZE: int = 40

var _label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	offset_top = -(PANEL_HEIGHT + BOTTOM_MARGIN)
	offset_bottom = -BOTTOM_MARGIN
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(panel)

	_label = Label.new()
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(_label)


## Shows the info of one tile.
func show_tile(x: int, y: int, type_name: String, elevation: int, water_index: int, is_dry: bool) -> void:
	var state: String = "DRY now" if is_dry else "UNDERWATER now"
	_label.text = "Tile (%d, %d)  %s\nElevation %d  |  Water index %d\n%s" % [
		x, y, type_name, elevation, water_index, state
	]
	visible = true


func hide_tile() -> void:
	visible = false
