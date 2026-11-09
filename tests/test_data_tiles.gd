extends GutTest
## Tests for the C03 data files: tiles.json, island files and the new tuning keys.


func test_tiles_are_loaded() -> void:
	var elevations: Dictionary = {"DEEP": -1, "SEABED": 0, "REEF": 1, "MUDFLAT": 2, "SHORE": 3, "LAND": 4}
	assert_eq(Data.tiles.size(), 6)
	for type_name: String in elevations:
		assert_true(Data.tiles.has(type_name), type_name)
		var tile_def: Dictionary = Data.tiles.get(type_name, {})
		assert_eq(int(tile_def.get("elevation", -99)), elevations[type_name], type_name)


func test_tile_colors_are_hex() -> void:
	for type_name: String in Data.tiles:
		var tile_def: Dictionary = Data.tiles[type_name]
		var color_text: String = str(tile_def.get("color", ""))
		assert_true(color_text.begins_with("#") and color_text.length() == 7, type_name)


func test_island_file_loads() -> void:
	var raw: Dictionary = Data.load_island("home_isle")
	assert_eq(str(raw.get("id", "")), "home_isle")


func test_missing_island_returns_empty() -> void:
	assert_eq(Data.load_island("no_such_island").size(), 0)


func test_new_tuning_keys() -> void:
	assert_eq(Data.tuning_int("tile_px"), 64)
	assert_eq(Data.tuning_int("camera_margin_tiles"), 2)
	assert_eq(Data.tuning_int("tap_max_move_px"), 20)
	assert_almost_eq(float(Data.tuning.get("water_tint_alpha_min", -1.0)), 0.25, 0.0001)
	assert_almost_eq(float(Data.tuning.get("water_tint_alpha_max", -1.0)), 0.55, 0.0001)
