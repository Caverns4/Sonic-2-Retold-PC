extends Node2D

@export var debug_only: bool = false
@export var currentCharacter:Global.CHARACTERS = 1 as Global.CHARACTERS
# alternative spawning location
func _ready() -> void:
	if debug_only and !Global.debug_mode:
		return
	if ((currentCharacter == Global.PlayerChar1 or currentCharacter == 0)
	 and Global.saved_checkpoint < 0):
		Global.players[0].global_position = global_position
		Global.players[0].camera.global_position = global_position
