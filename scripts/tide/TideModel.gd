class_name TideModel
extends RefCounted
## Pure tide math (02 section 5). No nodes, no autoload calls.
## Why: pure logic is easy to test. All numbers come from tuning.json.

const EVENT_NONE: String = "none"
const EVENT_SPRING: String = "spring"
const EVENT_SUPER_LOW: String = "super_low"

const PHASE_NAMES: Array[String] = ["LOW", "RISING", "HIGH", "FALLING"]
const PHASE_LOW: int = 0
const PHASE_HIGH: int = 2

var cycle_s: int = 1
var phase_s: int = 1
var epoch: int = 0
var spring_high_index: int = 0
var super_low_index: int = 0
var _base_indexes: Array[int] = []


## Reads the numbers from a tuning Dictionary (Data.tuning).
func _init(tuning: Dictionary) -> void:
	# maxi(1, ...) stops a divide by zero if the data is missing.
	cycle_s = maxi(1, int(tuning.get("tide_cycle_s", 0)))
	phase_s = maxi(1, int(tuning.get("phase_s", 0)))
	epoch = int(tuning.get("tide_epoch_unix", 0))
	spring_high_index = int(tuning.get("spring_high_index", 0))
	super_low_index = int(tuning.get("super_low_index", 0))
	var wi: Dictionary = tuning.get("water_index", {})
	for phase_name: String in PHASE_NAMES:
		if not wi.has(phase_name):
			Log.warn("TideModel", "Missing water_index for %s" % phase_name)
		_base_indexes.append(int(wi.get(phase_name, 0)))


## 0 LOW, 1 RISING, 2 HIGH, 3 FALLING.
@warning_ignore("integer_division")
func phase_index(t: int) -> int:
	return posmod(t - epoch, cycle_s) / phase_s


## Phase name: LOW, RISING, HIGH or FALLING.
func phase_name(t: int) -> String:
	return PHASE_NAMES[phase_index(t)]


## Water index without events.
func base_index(t: int) -> int:
	return _base_indexes[phase_index(t)]


## Water index with an event applied. Spring only changes HIGH. Super low only changes LOW.
func water_index(t: int, event: String = EVENT_NONE) -> int:
	var p: int = phase_index(t)
	if event == EVENT_SPRING and p == PHASE_HIGH:
		return spring_high_index
	if event == EVENT_SUPER_LOW and p == PHASE_LOW:
		return super_low_index
	return _base_indexes[p]


## Unix time of the next phase boundary. Always after t.
func next_change(t: int) -> int:
	return t + (phase_s - posmod(t - epoch, phase_s))


## Unix time when the current cycle started.
func cycle_start(t: int) -> int:
	return t - posmod(t - epoch, cycle_s)


## Smooth water level from 0 to 1. For visuals only (R-TIDE-8).
func visual_level(t: int) -> float:
	var progress: float = float(posmod(t - epoch, cycle_s)) / float(cycle_s)
	return 0.5 - 0.5 * cos(TAU * progress)


## A tile is underwater when the water index is higher than its elevation.
static func is_underwater(elevation: int, index: int) -> bool:
	return index > elevation


## A tile is dry when the water index is not higher than its elevation.
static func is_dry(elevation: int, index: int) -> bool:
	return index <= elevation


## A boat can pass when the tile is underwater and the water is deep enough for the draft.
static func can_boat_pass(elevation: int, index: int, draft: int) -> bool:
	return is_underwater(elevation, index) and index >= elevation + draft


## Counts the seconds between t0 and t1 where predicate(water_index) is true.
## Walks one phase segment at a time. With the 48 h cap this is cheap.
## predicate: Callable that takes an int index and returns bool.
func active_seconds(t0: int, t1: int, predicate: Callable, event: String = EVENT_NONE) -> int:
	var total: int = 0
	var cursor: int = t0
	while cursor < t1:
		var segment_end: int = mini(next_change(cursor), t1)
		if predicate.call(water_index(cursor, event)):
			total += segment_end - cursor
		cursor = segment_end
	return total
