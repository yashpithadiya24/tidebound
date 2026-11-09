class_name TideWidget
extends Control
## Tide widget at the top center: color swatch, phase name, countdown (01 section 13, R-TIDE-7).
## Placeholder look. Color is never the only signal: the phase name is always text.

## Gap from the top. The debug strip (96 px button plus padding) sits above it.
const TOP_OFFSET: float = 120.0
const WIDGET_SIZE: Vector2 = Vector2(640, 120)
const SWATCH_SIZE: Vector2 = Vector2(80, 80)
const PHASE_FONT: int = 44
const TIME_FONT: int = 32

var _swatch: ColorRect
var _phase_label: Label
var _time_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	offset_top = TOP_OFFSET
	offset_bottom = TOP_OFFSET + WIDGET_SIZE.y
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = WIDGET_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(panel)

	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	panel.add_child(row)

	_swatch = ColorRect.new()
	_swatch.custom_minimum_size = SWATCH_SIZE
	row.add_child(_swatch)

	var texts: VBoxContainer = VBoxContainer.new()
	row.add_child(texts)
	_phase_label = Label.new()
	_phase_label.add_theme_font_size_override("font_size", PHASE_FONT)
	texts.add_child(_phase_label)
	_time_label = Label.new()
	_time_label.add_theme_font_size_override("font_size", TIME_FONT)
	texts.add_child(_time_label)

	EventBus.tide_phase_changed.connect(_on_tide_changed)
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_refresh)
	add_child(timer)
	_refresh()


func _on_tide_changed(_phase: String, _index: int) -> void:
	_refresh()


func _refresh() -> void:
	var phase: String = Tide.current_phase()
	_phase_label.text = phase
	var text: String = "Next in %s" % _format_time(Tide.seconds_to_next())
	if Tide.event_override == TideModel.EVENT_SPRING:
		text += " | spring"
	elif Tide.event_override == TideModel.EVENT_SUPER_LOW:
		text += " | super low"
	_time_label.text = text
	_swatch.color = _phase_color(phase)


func _phase_color(phase: String) -> Color:
	match phase:
		"LOW":
			return Color.html("#e8d9a8")
		"RISING":
			return Color.html("#4fb3d9")
		"HIGH":
			return Color.html("#1d5d9b")
		_:
			return Color.html("#3fbf9f")


@warning_ignore("integer_division")
func _format_time(total: int) -> String:
	return "%d:%02d:%02d" % [total / 3600, (total % 3600) / 60, total % 60]
