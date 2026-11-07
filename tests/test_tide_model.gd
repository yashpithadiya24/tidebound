extends GutTest
## Golden tests for TideModel (02 section 5). More tests are added in C02.5.

var model: TideModel


func before_each() -> void:
	model = TideModel.new(Data.tuning)


func test_phase_golden_table() -> void:
	var cases: Array = [
		[0, "LOW", 1],
		[5399, "LOW", 1],
		[5400, "RISING", 2],
		[10800, "HIGH", 3],
		[16200, "FALLING", 2],
		[21600, "LOW", 1],
		[1700000000, "HIGH", 3],
	]
	for c: Array in cases:
		var t: int = c[0]
		assert_eq(model.phase_name(t), c[1], "phase at t=%d" % t)
		assert_eq(model.water_index(t), c[2], "index at t=%d" % t)


func test_next_change_golden() -> void:
	assert_eq(model.next_change(1700000000), 1700001000)
	assert_eq(model.next_change(0), 5400)
	assert_eq(model.next_change(5399), 5400)
	assert_eq(model.next_change(5400), 10800)


func test_cycle_start() -> void:
	assert_eq(model.cycle_start(0), 0)
	assert_eq(model.cycle_start(21599), 0)
	assert_eq(model.cycle_start(21600), 21600)
	assert_eq(model.cycle_start(30000), 21600)


func test_spring_changes_only_high() -> void:
	assert_eq(model.water_index(10800, TideModel.EVENT_SPRING), 4)
	assert_eq(model.water_index(0, TideModel.EVENT_SPRING), 1)


func test_super_low_changes_only_low() -> void:
	assert_eq(model.water_index(0, TideModel.EVENT_SUPER_LOW), 0)
	assert_eq(model.water_index(10800, TideModel.EVENT_SUPER_LOW), 3)


func test_visual_level_is_between_0_and_1() -> void:
	for t: int in [0, 5400, 10800, 16200, 21599]:
		var level: float = model.visual_level(t)
		assert_between(level, 0.0, 1.0, "level at t=%d" % t)
	assert_almost_eq(model.visual_level(0), 0.0, 0.0001)
	assert_almost_eq(model.visual_level(10800), 1.0, 0.0001)
