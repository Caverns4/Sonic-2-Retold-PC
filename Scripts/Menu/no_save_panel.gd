extends DataSelectPanel


func _update_save_preview():
	await get_tree().process_frame
	%CharacterIcon.frame = character_id

func use():
	Global.PlayerChar1 = max(character_id,1)
	if character_id == 0:
		Global.PlayerChar2 = Global.CHARACTERS.TAILS 
	else:
		Global.PlayerChar2 = Global.CHARACTERS.NONE
	return true
