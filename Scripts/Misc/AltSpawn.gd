extends Node2D

@export var currentCharacter:Global.CHARACTERS = 1 as Global.CHARACTERS
# alternative spawning location
func _ready():
	if currentCharacter == Global.PlayerChar1-1 and Global.currentCheckPoint == -1:
		Global.players[0].global_position = global_position
		Global.players[0].camera.global_position = global_position
