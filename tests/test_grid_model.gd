extends GutTest
## Tests for GridModel (02 section 6, 01 section 3 tile table).

const TILE_PX: int = 64


## One row with every tile type: x = 0 DEEP, 1 SEABED, 2 REEF, 3 MUDFLAT, 4 SHORE, 5 LAND.
func _row_island() -> IslandData:
	return IslandData.from_dict({
		"id": "row",
		"width": 6,
		"height": 1,
		"legend": {"~": "DEEP", "s": "SEABED", "r": "REEF", "m": "MUDFLAT", "h": "SHORE", "L": "LAND"},
		"rows": ["~srmhL"],
	})


func _row_grid() -> GridModel:
	return GridModel.new(_row_island(), Data.tiles, TILE_PX)


func test_tile_types_and_elevations() -> void:
	var grid: GridModel = _row_grid()
	var names: Array[String] = ["DEEP", "SEABED", "REEF", "MUDFLAT", "SHORE", "LAND"]
	var elevations: Array[int] = [-1, 0, 1, 2, 3, 4]
	for x: int in range(6):
		assert_eq(grid.get_tile_type(x, 0), names[x], "type x=%d" % x)
		assert_eq(grid.get_elevation(x, 0), elevations[x], "elevation x=%d" % x)


func test_outside_the_grid() -> void:
	var grid: GridModel = _row_grid()
	assert_false(grid.in_bounds(-1, 0))
	assert_false(grid.in_bounds(6, 0))
	assert_false(grid.in_bounds(0, 1))
	assert_eq(grid.get_tile_type(6, 0), "")
	assert_eq(grid.get_elevation(0, 1), GridModel.OUTSIDE)
	assert_false(grid.is_dry_at(-1, 0, 1))
	assert_false(grid.is_underwater_at(-1, 0, 1))


## Dry or underwater for every tile type and every water index 0 to 4 (01 section 3, R-TIDE-5).
## Index 0 is super low tide, index 4 is spring tide.
func test_dry_and_wet_table() -> void:
	var grid: GridModel = _row_grid()
	var expected_dry: Dictionary = {
		"DEEP": [false, false, false, false, false],
		"SEABED": [true, false, false, false, false],
		"REEF": [true, true, false, false, false],
		"MUDFLAT": [true, true, true, false, false],
		"SHORE": [true, true, true, true, false],
		"LAND": [true, true, true, true, true],
	}
	for x: int in range(6):
		var type_name: String = grid.get_tile_type(x, 0)
		var want_row: Array = expected_dry[type_name]
		for index: int in range(5):
			var want_dry: bool = want_row[index]
			var label: String = "%s at index %d" % [type_name, index]
			assert_eq(grid.is_dry_at(x, 0, index), want_dry, label)
			assert_eq(grid.is_underwater_at(x, 0, index), not want_dry, label)


func test_world_to_tile() -> void:
	var grid: GridModel = _row_grid()
	assert_eq(grid.world_to_tile(Vector2(0, 0)), Vector2i(0, 0))
	assert_eq(grid.world_to_tile(Vector2(63.9, 63.9)), Vector2i(0, 0))
	assert_eq(grid.world_to_tile(Vector2(64, 0)), Vector2i(1, 0))
	assert_eq(grid.world_to_tile(Vector2(-0.1, 0)), Vector2i(-1, 0))


func test_tile_to_world() -> void:
	var grid: GridModel = _row_grid()
	assert_eq(grid.tile_to_world(2, 3), Vector2(128, 192))


func test_pixel_size() -> void:
	var grid: GridModel = _row_grid()
	assert_eq(grid.pixel_size(), Vector2(384, 64))


func test_unknown_tile_type_is_open_sea() -> void:
	var island: IslandData = IslandData.from_dict({
		"id": "odd",
		"width": 1,
		"height": 1,
		"legend": {"?": "WEIRD"},
		"rows": ["?"],
	})
	var grid: GridModel = GridModel.new(island, Data.tiles, TILE_PX)
	assert_eq(grid.get_tile_type(0, 0), "WEIRD")
	assert_eq(grid.get_elevation(0, 0), GridModel.FALLBACK_ELEVATION)


func test_invalid_island_gives_empty_grid() -> void:
	var grid: GridModel = GridModel.new(IslandData.from_dict({}), Data.tiles, TILE_PX)
	assert_eq(grid.width, 0)
	assert_eq(grid.height, 0)
	assert_false(grid.in_bounds(0, 0))


## Spot checks on the real island. (5,4) is the tile fixed by D-025.
func test_home_isle_spot_checks() -> void:
	var island: IslandData = IslandData.from_dict(Data.load_island("home_isle"))
	var grid: GridModel = GridModel.new(island, Data.tiles, Data.tuning_int("tile_px"))
	assert_eq(grid.get_tile_type(0, 0), "DEEP")
	assert_eq(grid.get_tile_type(2, 1), "SEABED")
	assert_eq(grid.get_tile_type(3, 4), "MUDFLAT")
	assert_eq(grid.get_tile_type(4, 4), "SHORE")
	assert_eq(grid.get_tile_type(5, 4), "SHORE")
	assert_eq(grid.get_tile_type(6, 4), "LAND")
	assert_eq(grid.get_tile_type(6, 6), "LAND")
	assert_eq(grid.pixel_size(), Vector2(1024, 1024))
