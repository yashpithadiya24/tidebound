class_name Log
extends RefCounted
## Static logger. It is not an autoload (see D-011).
## Why: logic classes can call it without a node. Release builds print only warnings and errors.


## Prints a debug message. Debug builds only.
static func info(tag: String, message: String) -> void:
	if OS.is_debug_build():
		print("[INFO][%s] %s" % [tag, message])


## Reports a problem that the game can survive (bad data, missing id).
static func warn(tag: String, message: String) -> void:
	push_warning("[%s] %s" % [tag, message])


## Reports a real error. Never use it to crash the game.
static func error(tag: String, message: String) -> void:
	push_error("[%s] %s" % [tag, message])
