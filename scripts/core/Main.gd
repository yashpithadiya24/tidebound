extends Control
## Root scene. Loads the island screen (D-028). The C01 boot text is gone.

const ISLAND_SCENE: String = "res://scenes/island/Island.tscn"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# This full-screen Control must not eat mouse and touch events (the camera needs them).
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var packed: PackedScene = load(ISLAND_SCENE) as PackedScene
	if packed == null:
		Log.error("Main", "Cannot load %s" % ISLAND_SCENE)
		return
	add_child(packed.instantiate())
