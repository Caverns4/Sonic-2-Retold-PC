extends DataSelectPanel


func _update_save_preview() -> void:
	await get_tree().process_frame
	%CharacterIcon.frame = character_id

func use() -> bool:
	GlobalFunctions.convert_player_mode_to_players(character_id)
	return true
