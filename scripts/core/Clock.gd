extends Node
## Game clock. All game logic reads time only from here (05 section 2).
## Why: one place for time makes time-travel tests possible (02 section 4).

## Seconds added to the real time. Works only in debug builds.
var debug_offset: int = 0

## Latest time we have seen. Kept in memory until C06 Save stores it (D-021).
## Why: if the device clock goes back, we ignore the jump (01 section 14, rule 6).
var last_seen_at: int = 0


## Returns unix seconds (UTC). Adds debug_offset in debug builds only.
## Never returns a time smaller than last_seen_at.
func now() -> int:
	var t: int = int(Time.get_unix_time_from_system())
	if OS.is_debug_build():
		t += debug_offset
	if t < last_seen_at:
		return last_seen_at
	last_seen_at = t
	return t


## Sets last_seen_at. C06 Save will call this after it loads a save.
## It never moves the guard backward.
func set_last_seen_at(value: int) -> void:
	last_seen_at = maxi(last_seen_at, value)


## Clears the debug offset and the backward guard. Used by the debug panel.
func reset_debug() -> void:
	debug_offset = 0
	last_seen_at = 0
