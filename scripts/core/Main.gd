extends Control
## C01 boot screen. Shows the game name and the live Clock.now() number.
## Placeholder only. The real home screen comes in C03.

var _clock_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(box)

	var title: Label = Label.new()
	title.text = "Tidebound"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 96)
	box.add_child(title)

	_clock_label = Label.new()
	_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clock_label.add_theme_font_size_override("font_size", 48)
	box.add_child(_clock_label)

	# A 1 second timer. Not _process, so no per-frame string work.
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_on_tick)
	add_child(timer)
	_on_tick()


func _on_tick() -> void:
	_clock_label.text = str(Clock.now())
