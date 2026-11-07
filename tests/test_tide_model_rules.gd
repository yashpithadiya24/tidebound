extends GutTest
## Rule tests for TideModel: passability, events and active_seconds (02 section 5).

var model: TideModel


func before_each() -> void:
	model = TideModel.new(Data.tuning)


## Predicate helpers for active_seconds. Tile elevation 2 is a mudflat.
func _is_wet_on_mud(index: int) -> bool:
	return TideModel.is_underwater(2, index)


func _is_dry_on_mud(index: int) -> bool:
	return TideModel.is_dry(2, index)


# --- Passability ---

func test_passability_golden_table() -> void:
	# [elevation, index, draft, expected]
	var cases: Array = [
		[1, 1, 1, false],   # reef, LOW, draft 1 (dry)
		[1, 2, 1, true],    # reef, RISING, draft 1
		[1, 2, 2, false],   # reef, RISING, draft 2
		[1, 3, 2, true],    # reef, HIGH, draft 2
		[2, 2, 1, false],   # mudflat, RISING, draft 1
		[2, 3, 1, true],    # mudflat, HIGH, draft 1
		[2, 3, 2, false],   # mudflat, HIGH, draft 2
		[2, 4, 2, true],    # mudflat, spring HIGH, draft 2
		[3, 3, 1, false],   # shore, HIGH, draft 1 (dry)
		[3, 4, 1, true],    # shore, spring HIGH, draft 1
		[0, 0, 1, false],   # seabed, super low, draft 1 (dry)
		[-1, 1, 2, true],   # deep, LOW, draft 2
	]
	for c: Array in cases:
		var result: bool = TideModel.can_boat_pass(c[0], c[1], c[2])
		assert_eq(result, c[3], "elev=%d index=%d draft=%d" % [c[0], c[1], c[2]])


func test_seabed_draft2_needs_index_2() -> void:
	# D-019: SEABED does not work at LOW for draft 2 boats.
	assert_false(TideModel.can_boat_pass(0, 1, 2), "seabed, LOW, draft 2")
	assert_true(TideModel.can_boat_pass(0, 2, 2), "seabed, RISING, draft 2")
	assert_true(TideModel.can_boat_pass(0, 1, 1), "seabed, LOW, draft 1")


func test_deep_draft2_blocked_at_super_low() -> void:
	# Known edge case. We keep the 02 formula as is (decision by the user).
	assert_false(TideModel.can_boat_pass(-1, 0, 2), "deep, super low, draft 2")
	assert_true(TideModel.can_boat_pass(-1, 0, 1), "deep, super low, draft 1")


func test_land_is_never_passable() -> void:
	for index: int in range(0, 5):
		assert_false(TideModel.can_boat_pass(4, index, 1), "land at index %d" % index)


func test_dry_and_underwater_are_opposites() -> void:
	for elevation: int in range(-1, 5):
		for index: int in range(0, 5):
			assert_ne(
				TideModel.is_dry(elevation, index),
				TideModel.is_underwater(elevation, index),
				"elev=%d index=%d" % [elevation, index]
			)


func test_negative_time_works() -> void:
	# posmod keeps the phase correct before the epoch. t = -1 is the last second of FALLING.
	assert_eq(model.phase_name(-1), "FALLING")
	assert_eq(model.next_change(-1), 0)


# --- active_seconds ---

func test_active_full_cycle_wet_and_dry() -> void:
	# Mud is wet only at HIGH (5400 s) and dry for the other 3 phases (16200 s).
	assert_eq(model.active_seconds(0, 21600, _is_wet_on_mud), 5400)
	assert_eq(model.active_seconds(0, 21600, _is_dry_on_mud), 16200)


func test_active_partial_segment() -> void:
	# 5000 to 6000: LOW until 5400 (index 1), then RISING (index 2). Predicate: index 1 only.
	var only_low: Callable = func(index: int) -> bool: return index == 1
	assert_eq(model.active_seconds(5000, 6000, only_low), 400)


func test_active_across_boundaries() -> void:
	# 10000 to 17000 covers part of RISING, all of HIGH (10800 to 16200), part of FALLING.
	assert_eq(model.active_seconds(10000, 17000, _is_wet_on_mud), 5400)


func test_active_empty_or_reversed_range() -> void:
	assert_eq(model.active_seconds(5000, 5000, _is_dry_on_mud), 0)
	assert_eq(model.active_seconds(6000, 5000, _is_dry_on_mud), 0)


func test_active_spring_event() -> void:
	var index_4: Callable = func(index: int) -> bool: return index >= 4
	assert_eq(model.active_seconds(0, 21600, index_4, TideModel.EVENT_SPRING), 5400)
	assert_eq(model.active_seconds(0, 21600, index_4), 0)


func test_active_super_low_event() -> void:
	var index_0: Callable = func(index: int) -> bool: return index <= 0
	assert_eq(model.active_seconds(0, 21600, index_0, TideModel.EVENT_SUPER_LOW), 5400)
	assert_eq(model.active_seconds(0, 21600, index_0), 0)


func test_active_48h_cap_size() -> void:
	# 48 h is 8 cycles. Mud is dry 16200 s per cycle.
	var cap: int = Data.tuning_int("offline_cap_s")
	assert_eq(model.active_seconds(0, cap, _is_dry_on_mud), 129600)


func test_active_dry_plus_wet_equals_total() -> void:
	var t0: int = 1234
	var t1: int = t0 + 100000
	var dry: int = model.active_seconds(t0, t1, _is_dry_on_mud)
	var wet: int = model.active_seconds(t0, t1, _is_wet_on_mud)
	assert_eq(dry + wet, 100000)
