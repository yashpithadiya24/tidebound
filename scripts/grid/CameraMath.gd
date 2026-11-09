class_name CameraMath
extends RefCounted
## Pure camera math (02 section 6). No nodes, so it is easy to test.


## Island rectangle grown by a margin on every side (pixels).
static func island_bounds(island_px: Vector2, margin_px: float) -> Rect2:
	var margin: Vector2 = Vector2(margin_px, margin_px)
	return Rect2(-margin, island_px + margin * 2.0)


## Keeps the view inside the bounds. view_size is the visible world size.
## If the view is bigger than the bounds on one axis, the camera centers on that axis.
static func clamp_center(center: Vector2, view_size: Vector2, bounds: Rect2) -> Vector2:
	var half: Vector2 = view_size * 0.5
	var result: Vector2 = center
	if view_size.x >= bounds.size.x:
		result.x = bounds.position.x + bounds.size.x * 0.5
	else:
		result.x = clampf(center.x, bounds.position.x + half.x, bounds.end.x - half.x)
	if view_size.y >= bounds.size.y:
		result.y = bounds.position.y + bounds.size.y * 0.5
	else:
		result.y = clampf(center.y, bounds.position.y + half.y, bounds.end.y - half.y)
	return result


## Keeps the zoom between the tuning limits.
static func clamp_zoom(zoom_value: float, zoom_min: float, zoom_max: float) -> float:
	return clampf(zoom_value, zoom_min, zoom_max)
