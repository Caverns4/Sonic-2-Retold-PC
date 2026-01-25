extends Node2D

## The current Zone ID, for Global.ZONES
@export var zone_id = 0 as Global.ZONES

@export_group("Title Card Properties")
## If true, play the level card animator and use the Zone Name Text
@export var playLevelCard: bool = true
## Text to use in the Zone Name label.
@export var zone_name: String = "Emerald Hill"
## Text to use in the Zone label.
@export var zone_text: String = "Zone"
## Act ID
@export var act_number: int = 1


@export_group("Music")
@export var music = preload("res://Audio/Soundtrack/s2br_EmeraldHilll.ogg")
@export var music2P = preload("res://Audio/Soundtrack/s2br_Tropical.ogg")
@export var boss_theme = preload("res://Audio/Soundtrack/s2br_Boss.ogg")

@export_group("Features")
## Animals dropped from Badniks in this act.
@export_enum("Bird","Squirrel",
"Rabbit", "Chicken",
"Penguin", "Seal",
"Pig", "Eagle",
"Mouse", "Monkey",
"Turtle","Bear",
"Beaver","Fox")var animal1: int = 0
## Animals dropped from Badniks in this act.
@export_enum("Bird", "Squirrel",
"Rabbit", "Chicken",
"Penguin", "Seal",
"Pig", "Eagle",
"Mouse", "Monkey",
"Turtle", "Bear",
"Beaver","Fox")var animal2: int = 1
## If 0, the number of rings will be calculated automatically.
@export var ringsForPerfect: int = 0
@export_subgroup("Optional")
@export var waterSourceColor = preload("res://Graphics/Palettes/BasePal.png")
@export var waterReplaceColor = preload("res://Graphics/Palettes/WetPal.png")
@export var wind_force: Vector2 = Vector2.ZERO
@export var end_cutscene: bool = false

@export_group("Scrolling")
# Boundries
@export var defaultLeftBoundry: int  = 0
@export var defaultTopBoundry: int  = 0
@export var defaultRightBoundry: int = 16384
@export var defaultBottomBoundry: int = 2048

## If true, the top and bottom boundary will be ignored.
@export var y_wrap: bool = false

var zone_loader: String = "res://Scene/Presentation/ZoneLoader.tscn"
var twoPlayerWindow = preload("res://Scene/TwoPlayerScreenView.tscn")

func _ready():
	level_reset_data()
	Global.saved_zone_id = zone_id as Global.ZONES

	# Setup Boundries
	Global.y_wrap = y_wrap
	Global.hardBorderLeft  = defaultLeftBoundry
	Global.hardBorderRight = defaultRightBoundry
	Global.hardBorderTop    = defaultTopBoundry
	Global.hardBorderBottom  = defaultBottomBoundry

	call_deferred("setup_hud_properties")
	if Global.two_player_mode == true:
		var twoPlayerScene = twoPlayerWindow.instantiate()
		add_child(twoPlayerScene)

func setup_hud_properties():
	if Global.hud:
		Global.hud.playLevelCard = playLevelCard
		Global.hud.end_cutscene = end_cutscene
		Global.hud.waterSourceColor = waterSourceColor
		Global.hud.waterReplaceColor = waterReplaceColor
		if ringsForPerfect <= 0:
			ringsForPerfect = get_tree().get_nodes_in_group("Rings").size()
			print(str(ringsForPerfect) + " rings to perfect.")
		Global.hud.ringsForPerfect = ringsForPerfect
		Global.hud.initialize_hud(zone_name,zone_text,act_number)

# used for stage starts, also used for returning from special stages
func level_reset_data(_playCard = true):
	Global.stageClearPhase = 0
	Global.fightingBoss = false
	SoundDriver.music.stop()
	# music handling
	var level_theme = null
	if SoundDriver.music != null:
		if music != null:
			if !Global.two_player_mode:
				level_theme = music
				
			else:
				level_theme = music2P
			SoundDriver.music.stream_paused = false
			SoundDriver.themes[SoundDriver.THEME.NORMAL] = level_theme
	
	if boss_theme:
		SoundDriver.themes[SoundDriver.THEME.BOSS] = boss_theme
	
	SoundDriver.currentTheme = SoundDriver.THEME.NORMAL
	SoundDriver.playMusic(level_theme,true)
	
	if Global.saved_checkpoint < 0:
		Global.levelTime = 0
		Global.levelTimeP2 = 0

	#Clear Object Arrays used within levels
	var index: int = 0
	while index < len(Global.slot_machines):
		if !is_instance_valid(Global.slot_machines[index]):
			Global.slot_machines.remove_at(index)
		else:
			index +=1
	
	# set next zone
	Global.next_zone_pointer = zone_loader
	
	# set animals
	Global.animals = [animal1,animal2]
	# if global hud and play card, run hud ready script
	if is_instance_valid(Global.hud): #_playCard and
		$HUD._ready()
