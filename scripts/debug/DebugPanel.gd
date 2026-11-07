extends Node
## Debug autoload (named "Debug"). Time travel and event buttons for testing the tide.
## Why: time travel is how we test tides (02 section 4). Debug builds only (02 section 14).

const LAYER: int = 100
const BUTTON_HEIGHT: int = 96
const FONT_SIZE: int = 36
const SECONDS_PER_HOUR: int = 3600

var _header: Button
var _body: VBoxContainer
var _info: Label


func _ready() -> void:
	if not OS.is_debug_build():
		return
	_build_ui()
	EventBus.tide_phase_changed.connect(_on_tide_changed)
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_update_text)
	add_child(timer)
	_update_text()


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = LAYER
	add_child(layer)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	layer.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	panel.add_child(box)

	_header = _make_button("")
	_header.pressed.connect(_toggle_body)
	box.add_child(_header)

	_body = VBoxContainer.new()
	_body.visible = false
	box.add_child(_body)

	_info = Label.new()
	_info.add_theme_font_size_override("font_size", FONT_SIZE)
	_body.add_child(_info)

	var time_row: HBoxContainer = HBoxContainer.new()
	_body.add_child(time_row)
	_add_button(time_row, "+1 h", _on_jump.bind(SECONDS_PER_HOUR))
	_add_button(time_row, "Next phase", _on_next_phase)
	_add_button(time_row, "+6 h", _on_jump.bind(6 * SECONDS_PER_HOUR))
	_add_button(time_row, "Reset", _on_reset)

	var event_row: HBoxContainer = HBoxContainer.new()
	_body.add_child(event_row)
	_add_button(event_row, "No event", _on_event.bind(TideModel.EVENT_NONE))
	_add_button(event_row, "Spring", _on_event.bind(TideModel.EVENT_SPRING))
	_add_button(event_row, "Super low", _on_event.bind(TideModel.EVENT_SUPER_LOW))


func _make_button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", FONT_SIZE)
	return button


func _add_button(row: HBoxContainer, text: String, callback: Callable) -> void:
	var button: Button = _make_button(text)
	button.pressed.connect(callback)
	row.add_child(button)


func _toggle_body() -> void:
	_body.visible = not _body.visible
	_update_text()


## Moves the debug clock forward and checks the tide at once.
func _on_jump(seconds: int) -> void:
	Clock.debug_offset += seconds
	Tide.refresh()
	_update_text()


## Jumps to the exact start of the next phase.
func _on_next_phase() -> void:
	var t: int = Clock.now()
	Clock.debug_offset += Tide.model.next_change(t) - t
	Tide.refresh()
	_update_text()


## Clears the debug offset and the backward guard (D-020).
func _on_reset() -> void:
	Clock.reset_debug()
	Tide.refresh()
	_update_text()


func _on_event(event: String) -> void:
	Tide.set_event_override(event)
	_update_text()


func _on_tide_changed(_phase: String, _index: int) -> void:
	_update_text()


func _update_text() -> void:
	if _header == null:
		return
	_header.text = "TIDE %s | idx %d | next in %s" % [
		Tide.current_phase(), Tide.current_index(), _format_time(Tide.seconds_to_next())
	]
	if _body.visible:
		_info.text = "Event: %s | Offset: %d s | Time: %d" % [
			Tide.event_override, Clock.debug_offset, Clock.now()
		]


@warning_ignore("integer_division")
func _format_time(total: int) -> String:
	return "%02d:%02d:%02d" % [total / 3600, (total % 3600) / 60, total % 60]
