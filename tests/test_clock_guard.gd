extends GutTest
## Tests for the Clock backward guard.


func before_each() -> void:
	Clock.reset_debug()


func after_each() -> void:
	Clock.reset_debug()


func test_clock_never_goes_backward() -> void:
	Clock.debug_offset = 1000
	var t1: int = Clock.now()
	Clock.debug_offset = 0
	var t2: int = Clock.now()
	assert_eq(t2, t1, "guard should hold the last seen time")


func test_guard_holds_a_future_saved_time() -> void:
	var future: int = int(Time.get_unix_time_from_system()) + 5000
	Clock.set_last_seen_at(future)
	assert_eq(Clock.now(), future)


func test_set_last_seen_at_does_not_move_back() -> void:
	Clock.set_last_seen_at(5000)
	Clock.set_last_seen_at(100)
	assert_eq(Clock.last_seen_at, 5000)


func test_old_last_seen_does_not_block_real_time() -> void:
	Clock.set_last_seen_at(100)
	var system_now: int = int(Time.get_unix_time_from_system())
	assert_almost_eq(Clock.now(), system_now, 2)


func test_reset_debug_clears_offset_and_guard() -> void:
	Clock.debug_offset = 1000
	Clock.now()
	Clock.reset_debug()
	var system_now: int = int(Time.get_unix_time_from_system())
	assert_eq(Clock.debug_offset, 0)
	assert_almost_eq(Clock.now(), system_now, 2)
