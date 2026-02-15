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

var skip_zones = [Global.ZONES.WOOD_GADGET,
Global.ZONES.JEWEL_GROTTO,
Global.ZONES.WINTER,
Global.ZONES.SAND_SHOWER,
Global.ZONES.TROPICAL,
Global.ZONES.SKY_FORTRESS,
Global.ZONES.DEATH_EGG]

## TODO: Scrap this

func update_menu_item(direction: int = 0):
	if !data:
		@warning_ignore("int_as_enum_without_cast")
		character_id = wrapi(character_id + direction,
		Global.PLAYER_MODES.SONIC_AND_TAILS,
		Global.PLAYER_MODES.RAY) as Global.PLAYER_MODES
		return true
	elif data[3] == Global.ZONES.ENDING:
		@warning_ignore("int_as_enum_without_cast")
		level_id = wrapi(level_id + direction,
		Global.ZONES.EMERALD_HILL,
		Global.ZONES.CYBER_CITY) as Global.ZONES
		while skip_zones.has(level_id):
			@warning_ignore("int_as_enum_without_cast")
			level_id = wrapi(level_id + direction,
			Global.ZONES.EMERALD_HILL,
			Global.ZONES.CYBER_CITY) as Global.ZONES
		
		return true
	return false



func use():
	Global.getPlayerIDsFromPlayerMode(character_id)
	Global.character_selection = character_id
	Global.saved_zone_id = level_id
	
	if data:
		Global.character_selection = data[0]
		Global.continues = data[2]
		Global.emeralds = data[4]
		Global.lives = data[5]
		Global.score = data[6]
	
	Global.current_save_index = save_game_id
	return true
	
