class_name IslandData
extends RefCounted
## One island map read from data/islands/<id>.json (03 section 12).
## Why: pure parsing with no nodes, so it is easy to test.
## Bad data gives valid = false and an empty island. It never crashes.

## Island id, for example "home_isle".
var id: String = ""
var width: int = 0
var height: int = 0
## Tile type name for each cell, row by row. Index = y * width + x.
var tile_types: PackedStringArray = PackedStringArray()
## Start anchor tile of the Harbor Hall. C04 decides how the anchor maps to the footprint.
var harbor_x: int = 0
var harbor_y: int = 0
## True only when the whole file was read without a problem.
var valid: bool = false


## Builds an IslandData from a parsed JSON Dictionary.
static func from_dict(data: Dictionary) -> IslandData:
	var island: IslandData = IslandData.new()
	island.valid = island._load(data)
	if not island.valid:
		island.width = 0
		island.height = 0
		island.tile_types = PackedStringArray()
	return island


## Reads and checks the data. Returns false at the first problem.
func _load(data: Dictionary) -> bool:
	id = str(data.get("id", ""))
	width = int(data.get("width", 0))
	height = int(data.get("height", 0))
	if width <= 0 or height <= 0:
		Log.warn("IslandData", "Bad size in island '%s'" % id)
		return false

	var legend_value: Variant = data.get("legend", null)
	var rows_value: Variant = data.get("rows", null)
	if typeof(legend_value) != TYPE_DICTIONARY or typeof(rows_value) != TYPE_ARRAY:
		Log.warn("IslandData", "Island '%s' needs a legend and rows" % id)
		return false
	var legend: Dictionary = legend_value
	var rows: Array = rows_value
	if rows.size() != height:
		Log.warn("IslandData", "Island '%s' has %d rows, expected %d" % [id, rows.size(), height])
		return false

	var types: PackedStringArray = PackedStringArray()
	for y: int in range(height):
		var row: String = str(rows[y])
		if row.length() != width:
			Log.warn("IslandData", "Island '%s' row %d has %d characters, expected %d" % [id, y, row.length(), width])
			return false
		for x: int in range(width):
			var ch: String = row[x]
			if not legend.has(ch):
				Log.warn("IslandData", "Island '%s' row %d: '%s' is not in the legend" % [id, y, ch])
				return false
			types.append(str(legend[ch]))
	tile_types = types

	var harbor_value: Variant = data.get("start_harbor", {})
	if typeof(harbor_value) == TYPE_DICTIONARY:
		var harbor: Dictionary = harbor_value
		harbor_x = int(harbor.get("x", 0))
		harbor_y = int(harbor.get("y", 0))
	return true
