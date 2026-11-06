extends Node
## Game clock. All game logic reads time only from here (05 section 2).
## Why: one place for time makes time-travel tests possible (02 section 4).

## Seconds added to the real time. Works only in debug builds.
var debug_offset: int = 0


## Returns unix seconds (UTC). Adds debug_offset in debug builds only.
func now() -> int:
	var base: int = int(Time.get_unix_time_from_system())
	if OS.is_debug_build():
		return base + debug_offset
	return base
