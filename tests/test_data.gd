extends GutTest
## Tests for the Data autoload.

const BAD_FILE: String = "user://bad_test.json"


func after_each() -> void:
	if FileAccess.file_exists(BAD_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(BAD_FILE))


func test_tuning_is_loaded() -> void:
	assert_false(Data.tuning.is_empty(), "tuning.json should load")


func test_tide_numbers_are_correct() -> void:
	assert_eq(Data.tuning_int("tide_cycle_s"), 21600)
	assert_eq(Data.tuning_int("phase_s"), 5400)
	assert_eq(Data.tuning_int("offline_cap_s"), 172800)


func test_missing_file_returns_empty() -> void:
	var result: Dictionary = Data.load_json_dict("res://data/does_not_exist.json")
	assert_true(result.is_empty())


func test_bad_json_returns_empty() -> void:
	var file: FileAccess = FileAccess.open(BAD_FILE, FileAccess.WRITE)
	file.store_string("{ this is not json")
	file.close()
	var result: Dictionary = Data.load_json_dict(BAD_FILE)
	assert_true(result.is_empty())
