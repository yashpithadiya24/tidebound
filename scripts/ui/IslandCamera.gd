class_name IslandCamera
extends Camera2D
## Pan (drag), zoom (wheel or pinch) and tap for the island view (C03).
## Why: input lives here, the math is in CameraMath (pure, tested).
## emulate_mouse_from_touch stays on (D-034): one finger arrives as mouse events,
## two fingers (pinch) arrive as touch events, and mouse pan is ignored while pinching.

## Emitted on a press and release with little movement. The position is in world pixels.
signal tapped(world_pos: Vector2)

## How much one mouse wheel step zooms.
const WHEEL_ZOOM_STEP: float = 1.1

var _bounds: Rect2 = Rect2()
var _zoom_min: float = 1.0
var _zoom_max: float = 1.0
var _tap_max_move: float = 0.0

var _pressing: bool = false
var _tap_cancelled: bool = false
var _press_pos: Vector2 = Vector2.ZERO
var _max_move: float = 0.0

var _touches: Dictionary = {}
var _pinch_dist: float = 0.0
var _pinch_center: Vector2 = Vector2.ZERO


## Call once after the camera is in the scene tree.
## fit_size: the size to fit on the screen at the start (the island, in pixels).
func setup(bounds: Rect2, fit_size: Vector2, zoom_min: float, zoom_max: float, tap_max_move: float) -> void:
	_bounds = bounds
	_zoom_min = zoom_min
	_zoom_max = zoom_max
	_tap_max_move = tap_max_move
	var view: Vector2 = get_viewport_rect().size
	var fit: float = minf(view.x / fit_size.x, view.y / fit_size.y)
	_apply(bounds.get_center(), fit)
	get_viewport().size_changed.connect(_on_viewport_resized)
	make_current()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_on_drag(event as InputEventScreenDrag)
	elif event is InputEventMouseButton:
		_on_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_on_mouse_motion(event as InputEventMouseMotion)


func _on_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touches[event.index] = event.position
		if _touches.size() >= 2:
			_tap_cancelled = true
			_start_pinch()
	else:
		_touches.erase(event.index)
		if _touches.size() >= 2:
			_start_pinch()
		else:
			_pinch_dist = 0.0


func _start_pinch() -> void:
	var points: Array = _touches.values()
	var a: Vector2 = points[0]
	var b: Vector2 = points[1]
	_pinch_dist = a.distance_to(b)
	_pinch_center = (a + b) * 0.5


func _on_drag(event: InputEventScreenDrag) -> void:
	_touches[event.index] = event.position
	if _touches.size() < 2 or _pinch_dist <= 0.0:
		return
	var points: Array = _touches.values()
	var a: Vector2 = points[0]
	var b: Vector2 = points[1]
	var dist: float = a.distance_to(b)
	if dist <= 0.0:
		return
	var center: Vector2 = (a + b) * 0.5
	_pan_screen(center - _pinch_center)
	_zoom_at(center, zoom.x * dist / _pinch_dist)
	_pinch_dist = dist
	_pinch_center = center


func _on_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_zoom_at(event.position, zoom.x * WHEEL_ZOOM_STEP)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_zoom_at(event.position, zoom.x / WHEEL_ZOOM_STEP)
	elif event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressing = true
			_press_pos = event.position
			_max_move = 0.0
			_tap_cancelled = _touches.size() >= 2
		else:
			if _pressing and not _tap_cancelled and _max_move <= _tap_max_move:
				tapped.emit(_screen_to_world(event.position))
			_pressing = false


func _on_mouse_motion(event: InputEventMouseMotion) -> void:
	if not _pressing:
		return
	_max_move = maxf(_max_move, event.position.distance_to(_press_pos))
	# A small movement is still a tap. A pinch uses the touch events instead.
	if _max_move <= _tap_max_move or _touches.size() >= 2:
		return
	_pan_screen(event.relative)


func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return position + (screen_pos - get_viewport_rect().size * 0.5) / zoom.x


## Zooms and keeps the world point under screen_pos where it is.
func _zoom_at(screen_pos: Vector2, new_zoom: float) -> void:
	var z: float = CameraMath.clamp_zoom(new_zoom, _zoom_min, _zoom_max)
	var anchor: Vector2 = _screen_to_world(screen_pos)
	var offset: Vector2 = screen_pos - get_viewport_rect().size * 0.5
	_apply(anchor - offset / z, z)


func _pan_screen(delta_screen: Vector2) -> void:
	_apply(position - delta_screen / zoom.x, zoom.x)


func _apply(center: Vector2, new_zoom: float) -> void:
	var z: float = CameraMath.clamp_zoom(new_zoom, _zoom_min, _zoom_max)
	var view_world: Vector2 = get_viewport_rect().size / z
	position = CameraMath.clamp_center(center, view_world, _bounds)
	zoom = Vector2(z, z)


func _on_viewport_resized() -> void:
	_apply(position, zoom.x)
