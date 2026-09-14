extends Node

@export var eggman: CutsceneEggman = null

var input_abc: float = 0.0
var input_x: float = 0.0
var input_y: float = 0.0

func _ready() -> void:
	if eggman:
		eggman.controller = self
		
