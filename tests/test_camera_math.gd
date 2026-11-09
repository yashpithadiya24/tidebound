extends GutTest
## Tests for CameraMath (02 section 6).

const BOUNDS: Rect2 = Rect2(-128, -128, 1280, 1280)


func test_island_bounds_adds_margin() -> void:
	var bounds: Rect2 = CameraMath.island_bounds(Vector2(1024, 1024), 128.0)
	assert_eq(bounds.position, Vector2(-128, -128))
	assert_eq(bounds.size, Vector2(1280, 1280))


func test_center_inside_is_not_changed() -> void:
	var result: Vector2 = CameraMath.clamp_center(Vector2(512, 512), Vector2(500, 500), BOUNDS)
	assert_eq(result, Vector2(512, 512))


func test_clamp_at_top_left() -> void:
	var result: Vector2 = CameraMath.clamp_center(Vector2(0, 0), Vector2(500, 500), BOUNDS)
	assert_eq(result, Vector2(122, 122))


func test_clamp_at_bottom_right() -> void:
	var result: Vector2 = CameraMath.clamp_center(Vector2(2000, 2000), Vector2(500, 500), BOUNDS)
	assert_eq(result, Vector2(902, 902))


func test_big_view_is_centered() -> void:
	var result: Vector2 = CameraMath.clamp_center(Vector2(0, 0), Vector2(2000, 3000), BOUNDS)
	assert_eq(result, Vector2(512, 512))


func test_axes_are_independent() -> void:
	var result: Vector2 = CameraMath.clamp_center(Vector2(0, 0), Vector2(500, 3000), BOUNDS)
	assert_eq(result, Vector2(122, 512))


func test_clamp_zoom() -> void:
	assert_almost_eq(CameraMath.clamp_zoom(2.0, 0.6, 1.6), 1.6, 0.0001)
	assert_almost_eq(CameraMath.clamp_zoom(0.1, 0.6, 1.6), 0.6, 0.0001)
	assert_almost_eq(CameraMath.clamp_zoom(1.0, 0.6, 1.6), 1.0, 0.0001)
