extends GutTest
## Tests for the Tide autoload. Time travel uses Clock.debug_offset (debug builds only).


func before_each() -> void:
	Clock.reset_debug()
	Tide.set_event_override(TideModel.EVENT_NONE)


func after_each() -> void:
	Clock.reset_debug()
	Tide.set_event_override(TideModel.EVENT_NONE)


## Moves the clock to the start of the next time the given phase begins.
func _jump_to_phase(phase_i: int) -> void:
	var t: int = Clock.now()
	while Tide.model.phase_index(t) != phase_i:
		t = Tide.model.next_change(t)
	Clock.debug_offset += t - Clock.now()
	Tide.refresh()


func test_signal_when_phase_changes() -> void:
	if not OS.is_debug_build():
		pending("time travel works only in debug builds")
		return
	watch_signals(EventBus)
	var t: int = Clock.now()
	Clock.debug_offset += Tide.model.next_change(t) - t
	Tide.refresh()
	assert_signal_emit_count(EventBus, "tide_phase_changed", 1)


func test_no_signal_when_nothing_changes() -> void:
	watch_signals(EventBus)
	Tide.refresh()
	Tide.refresh()
	assert_signal_not_emitted(EventBus, "tide_phase_changed")


func test_signal_carries_phase_and_index() -> void:
	if not OS.is_debug_build():
		pending("time travel works only in debug builds")
		return
	_jump_to_phase(0)
	watch_signals(EventBus)
	_jump_to_phase(1)
	assert_signal_emitted_with_parameters(EventBus, "tide_phase_changed", ["RISING", 2])


func test_spring_event_raises_high_index() -> void:
	if not OS.is_debug_build():
		pending("time travel works only in debug builds")
		return
	_jump_to_phase(2)
	assert_eq(Tide.current_index(), 3)
	watch_signals(EventBus)
	Tide.set_event_override(TideModel.EVENT_SPRING)
	assert_eq(Tide.current_index(), 4)
	assert_signal_emitted_with_parameters(EventBus, "tide_phase_changed", ["HIGH", 4])


func test_super_low_event_lowers_low_index() -> void:
	if not OS.is_debug_build():
		pending("time travel works only in debug builds")
		return
	_jump_to_phase(0)
	assert_eq(Tide.current_index(), 1)
	Tide.set_event_override(TideModel.EVENT_SUPER_LOW)
	assert_eq(Tide.current_index(), 0)


func test_seconds_to_next_is_in_range() -> void:
	var left: int = Tide.seconds_to_next()
	assert_between(left, 1, Data.tuning_int("phase_s"))
