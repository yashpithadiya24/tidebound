extends GutTest
## Tests for the Clock autoload.


func after_each() -> void:
	Clock.debug_offset = 0


func test_now_is_close_to_system_time() -> void:
	var system_now: int = int(Time.get_unix_time_from_system())
	assert_almost_eq(Clock.now(), system_now, 2, "now() should match system time")


func test_debug_offset_is_added_in_debug_builds() -> void:
	if not OS.is_debug_build():
		pending("offset works only in debug builds")
		return
	Clock.debug_offset = 3600
	var expected: int = int(Time.get_unix_time_from_system()) + 3600
	assert_almost_eq(Clock.now(), expected, 2, "offset should be added")
