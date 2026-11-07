extends Node
## Tide autoload. Checks the tide once per second and emits tide_phase_changed.
## Why: one place owns the live tide. The math is in TideModel (pure, tested).
## Own 1 s Timer for now. A later chat can move it to the Game tick (02 section 3).

## Pure tide math. Built from tuning.json in _ready.
var model: TideModel

## Current event: "none", "spring" or "super_low".
## Only the debug panel sets it until C14 (D-021).
var event_override: String = TideModel.EVENT_NONE

var _last_phase_index: int = -1
var _last_water_index: int = -1


func _ready() -> void:
	model = TideModel.new(Data.tuning)
	_remember_state()
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(refresh)
	add_child(timer)


## Phase name now: LOW, RISING, HIGH or FALLING.
func current_phase() -> String:
	return model.phase_name(Clock.now())


## Water index now, with the event applied.
func current_index() -> int:
	return model.water_index(Clock.now(), event_override)


## Seconds until the next phase starts.
func seconds_to_next() -> int:
	var t: int = Clock.now()
	return model.next_change(t) - t


## Sets the event and checks the tide at once, so the change shows without waiting.
func set_event_override(event: String) -> void:
	event_override = event
	refresh()


## Compares the tide with the last known state and emits the signal if it changed.
## Called every second by the timer. Tests and the debug panel call it after a time jump.
func refresh() -> void:
	var t: int = Clock.now()
	var phase_i: int = model.phase_index(t)
	var water_i: int = model.water_index(t, event_override)
	if phase_i == _last_phase_index and water_i == _last_water_index:
		return
	_last_phase_index = phase_i
	_last_water_index = water_i
	EventBus.tide_phase_changed.emit(model.phase_name(t), water_i)


func _remember_state() -> void:
	var t: int = Clock.now()
	_last_phase_index = model.phase_index(t)
	_last_water_index = model.water_index(t, event_override)
