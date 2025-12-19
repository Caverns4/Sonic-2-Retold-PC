@tool
extends Node2D

@export var character_id: Global.PLAYER_MODES = 0 as Global.PLAYER_MODES
@export var level_id: Global.ZONES

var selected: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%CharacterIcon.frame = character_id
	%LevelIcon.frame = level_id


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		%CharacterIcon.frame = character_id
		%LevelIcon.frame = level_id
		return

func update_selection_state(state: bool) -> void:
	if state:
		$DataBox.self_modulate = Color.YELLOW
	else:
		$DataBox.self_modulate = Color.WHITE

func use():
	Global.getPlayerIDsFromPlayerMode(character_id)
	Global.saved_zone_id = level_id
	Global.character_selection = character_id
	return true
	
