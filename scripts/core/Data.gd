extends Node
## Loads game data from data/*.json (02 section 3, rule 5).
## Why: one place reads JSON, so no magic numbers live in game code.

const TUNING_PATH: String = "res://data/tuning.json"
const TILES_PATH: String = "res://data/tiles.json"
const ISLAND_DIR: String = "res://data/islands/"

## Content of data/tuning.json. Empty if the file is missing or bad.
var tuning: Dictionary = {}

## Content of data/tiles.json (tile type name -> elevation and color). Empty if bad.
var tiles: Dictionary = {}


func _ready() -> void:
	tuning = load_json_dict(TUNING_PATH)
	tiles = load_json_dict(TILES_PATH)


## Reads one JSON file and returns it as a Dictionary.
## Returns an empty Dictionary on any problem, so the game never crashes on bad data.
func load_json_dict(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		Log.warn("Data", "Missing file: %s" % path)
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var json: JSON = JSON.new()
	var err: Error = json.parse(text)
	if err != OK:
		Log.warn("Data", "Bad JSON in %s (line %d): %s" % [path, json.get_error_line(), json.get_error_message()])
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		Log.warn("Data", "JSON is not a dictionary: %s" % path)
		return {}
	var result: Dictionary = json.data
	return result


## Reads data/islands/<id>.json. Returns an empty Dictionary on any problem.
func load_island(id: String) -> Dictionary:
	return load_json_dict("%s%s.json" % [ISLAND_DIR, id])


## Returns one tuning number as an int. JSON numbers load as floats, so we convert here.
## Returns 0 and logs a warning if the key is missing.
func tuning_int(key: String) -> int:
	if not tuning.has(key):
		Log.warn("Data", "Missing tuning key: %s" % key)
		return 0
	return int(tuning[key])
