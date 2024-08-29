extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_TitleScreen.ogg")
@export var nextZone = load("res://Scene/Zones/ChunkZone.tscn")
@export var testScene = load("res://Scene/Presentation/CharacterSelect.tscn")
@export var returnScene = load("res://Scene/Presentation/PoweredByWorlds.tscn")

var titleEnd = false
var menuActive = false
var menuEntry = 0
var menuIconYOff = [4,20,12]
var particlesDone = false
var menuText = [
	"[color=#eeee00]1 PLAYER[/color]\n\n2 PLAYER VS",
	"1 PLAYER\n\n[color=eeee00]2 PLAYER VS[/color]",
	"\n[color=eeee00]LEVEL SELECT[/color]"
]

var parallaxBackgrounds = [
	"res://Scene/Backgrounds/00-EmeraldHill.tscn",
	"res://Scene/Backgrounds/01-HiddenPalace.tscn",
	"res://Scene/Backgrounds/02-HillTop.tscn",
	"res://Scene/Backgrounds/03-ChemicalPlant.tscn"
]

var paraOffsets = [
	0,
	-216,
	0,
	0,
	0,
]


func _ready():
	Global.TwoPlayer = false
	Global.music.stream = music
	Global.music.play()
	
	var zoneIndex = min(Global.savedZoneID,parallaxBackgrounds.size()-1)
	var parallax = parallaxBackgrounds[zoneIndex]
	var scene = load(parallax)
	var instance = scene.instantiate()
	instance.scroll_base_offset.y = paraOffsets[zoneIndex]
	add_child(instance)
	#UpdateMenuDisplay()
	if nextZone != null:
		Global.nextZone = nextZone

func _process(delta):
	if $CanvasLayer/Labels.visible == true and !titleEnd:
		menuActive = true
	
	$Worlds.global_position.x += (4*60*delta)
	# animate cogs
	#$BackCog.rotate(delta*speed)
	#$BigCog.rotate(-delta*2*speed)
	#$BigCog/CogCircle.rotate(delta*2*speed)
	#$Sonic/Cog.rotate(-delta*1.5*speed)
	$Celebrations.global_position.x += (4*60*delta)
	
	if $Worlds.global_position.x >= 3760 and particlesDone == false:
		$Celebrations.emitting = true
		particlesDone = true
	
	if $Worlds.global_position.x >= 4600 and !titleEnd:
		menuActive = false
		titleEnd = true
		Global.main.change_scene_to_file(returnScene,"FadeOut","FadeOut",1)

func _input(event):
	#if menuActive and !titleEnd:
	#	if Input.is_action_just_pressed("gm_down"):
	#		menuEntry +=1
	#	if Input.is_action_just_pressed("gm_up"):
	#		menuEntry -=1
	#menuEntry = wrapi(menuEntry,0,3)
	#UpdateMenuDisplay()
	
	# end title on start press
	if event.is_action_pressed("gm_pause") and !titleEnd and menuActive:
		MenuOptionChosen()
		
func MenuOptionChosen():
	#if Global.music.get_playback_position() < 14.0:
	#	Global.music.seek(14.0)
	if Input.is_action_pressed("gm_action") and menuEntry == 0:
		menuEntry = 2
	if Input.is_action_pressed("gm_action3"):
		Global.TwoPlayer = true
	
	match menuEntry:
		0:
			titleEnd = true
			Global.main.change_scene_to_file(nextZone,"FadeOut","FadeOut",1)
		1:
			titleEnd = true
			Global.TwoPlayer = true
			Global.PlayerChar1 = Global.CHARACTERS.SONIC
			Global.PlayerChar2 = Global.CHARACTERS.TAILS
			Global.main.change_scene_to_file(testScene,"FadeOut","FadeOut",1)
		2:
			titleEnd = true
			Global.main.change_scene_to_file(testScene,"FadeOut","FadeOut",1)
	
	
func UpdateMenuDisplay():
	$CanvasLayer/Labels/TitleMenu/MenuIcon.position.y = menuIconYOff[menuEntry]
	$CanvasLayer/Labels/TitleMenu/Text.text = menuText[menuEntry]
