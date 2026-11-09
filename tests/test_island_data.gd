extends GutTest
## Tests for IslandData (03 section 12, D-025, D-026).


func _small_dict() -> Dictionary:
	return {
		"id": "tiny",
		"width": 3,
		"height": 2,
		"legend": {"~": "DEEP", "r": "REEF", "L": "LAND"},
		"rows": ["~r~", "rLr"],
		"start_harbor": {"x": 1, "y": 1},
	}


func test_small_island_is_read() -> void:
	var island: IslandData = IslandData.from_dict(_small_dict())
	assert_true(island.valid)
	assert_eq(island.id, "tiny")
	assert_eq(island.width, 3)
	assert_eq(island.height, 2)
	assert_eq(island.tile_types[0], "DEEP")
	assert_eq(island.tile_types[1], "REEF")
	assert_eq(island.tile_types[4], "LAND")
	assert_eq(island.harbor_x, 1)
	assert_eq(island.harbor_y, 1)


func test_wrong_row_length_is_invalid() -> void:
	var data: Dictionary = _small_dict()
	data["rows"] = ["~r", "rLr"]
	var island: IslandData = IslandData.from_dict(data)
	assert_false(island.valid)
	assert_eq(island.width, 0)


func test_wrong_row_count_is_invalid() -> void:
	var data: Dictionary = _small_dict()
	data["rows"] = ["~r~"]
	assert_false(IslandData.from_dict(data).valid)


func test_unknown_legend_char_is_invalid() -> void:
	var data: Dictionary = _small_dict()
	data["rows"] = ["~x~", "rLr"]
	assert_false(IslandData.from_dict(data).valid)


func test_missing_keys_is_invalid() -> void:
	assert_false(IslandData.from_dict({}).valid)


func test_bad_size_is_invalid() -> void:
	var data: Dictionary = _small_dict()
	data["width"] = 0
	assert_false(IslandData.from_dict(data).valid)


## D-025: every row of home_isle must be 16 characters wide.
func test_home_isle_rows_are_16_wide() -> void:
	var raw: Dictionary = Data.load_island("home_isle")
	var rows: Array = raw.get("rows", [])
	assert_eq(rows.size(), 16)
	for y: int in range(rows.size()):
		var row: String = str(rows[y])
		assert_eq(row.length(), 16, "row %d" % y)


func test_home_isle_is_valid_16_by_16() -> void:
	var island: IslandData = IslandData.from_dict(Data.load_island("home_isle"))
	assert_true(island.valid)
	assert_eq(island.width, 16)
	assert_eq(island.height, 16)
	assert_eq(island.tile_types.size(), 256)


## D-026: the Harbor Hall starts at (6,6).
func test_home_isle_start_harbor_is_6_6() -> void:
	var island: IslandData = IslandData.from_dict(Data.load_island("home_isle"))
	assert_eq(island.harbor_x, 6)
	assert_eq(island.harbor_y, 6)


## The 3x3 block from the start tile must be all LAND (03 section 12).
func test_home_isle_harbor_footprint_is_land() -> void:
	var island: IslandData = IslandData.from_dict(Data.load_island("home_isle"))
	for dy: int in range(3):
		for dx: int in range(3):
			var index: int = (island.harbor_y + dy) * island.width + island.harbor_x + dx
			assert_eq(island.tile_types[index], "LAND", "dx %d dy %d" % [dx, dy])
