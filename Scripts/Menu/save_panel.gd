extends DataSelectPanel

var level_id: Global.ZONES
@onready var text_label: Label = $Label

func _update_save_preview():
	await get_tree().process_frame
	data = Global.LoadSaveGameSlotData(save_game_id)
	if data:
		character_id = data[0]
		level_id = data[3]
		text_label.text = "file " + str(save_game_id).pad_zeros(2)
		
	%CharacterIcon.frame = character_id
	%LevelIcon.frame = level_id


func use():
	if !data:
		GlobalFunctions.convert_player_mode_to_players(character_id)
		Global.character_selection = character_id
		Global.saved_zone_id = level_id
	else:
		GlobalFunctions.convert_player_mode_to_players(character_id)
		Global.character_selection = data[0]
		Global.continues = data[2]
		Global.emeralds = data[4]
		Global.lives = data[5]
		Global.score = data[6]
	
	Global.current_save_index = save_game_id
	return true
	
