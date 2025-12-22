@tool
extends DataSelectPanel


func _ready() -> void:
	%CharacterIcon.frame = character_id


func _process(_delta: float) -> void:
	%CharacterIcon.frame = character_id


func update_selection_state(state: bool) -> void:
	if state:
		$DataBox.modulate = Color.YELLOW
	else:
		$DataBox.modulate = Color.WHITE

func update_menu_item(direction: int = 0):
	@warning_ignore("int_as_enum_without_cast")
	character_id += direction
	character_id = wrapi(
		character_id,
		Global.PLAYER_MODES.SONIC_AND_TAILS,
		Global.PLAYER_MODES.RAY) as Global.PLAYER_MODES


func use():
	Global.current_save_index = 0
	Global.getPlayerIDsFromPlayerMode(character_id)
	Global.saved_zone_id = Global.ZONES.EMERALD_HILL
	Global.character_selection = character_id
	return true
	
