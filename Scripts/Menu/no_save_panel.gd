extends DataSelectPanel

var level_id: Global.ZONES = Global.ZONES.EMERALD_HILL

func use():
	Global.PlayerChar1 = max(character_id,1)
	if character_id == 0:
		Global.PlayerChar2 = Global.CHARACTERS.TAILS 
	else:
		Global.PlayerChar2 = Global.CHARACTERS.NONE
	return true
