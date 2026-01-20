extends Node

@export_node_path var eggman_path

var eggman: CutsceneControlledCharacter = null

var input_abc: float = 0.0
var input_x: float = 0.0
var input_y: float = 0.0

func _ready() -> void:
	if eggman_path:
		var node = get_node_or_null(eggman_path)
		if node is CutsceneControlledCharacter:
			eggman = node
			eggman.controller = self
		
