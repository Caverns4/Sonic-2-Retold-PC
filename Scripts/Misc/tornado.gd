extends CharacterBody2D

# This object doesn't do much on its own; It simply updates graphics. All controls are extrnal.

@export_enum("Static Character","Player 1","Player 2","Inheret") var pilotType = 0
@export var pilot = Global.CHARACTERS.SONIC
@export_enum("Left","Right") var startDirection = 1

var inheritedPilots = [
	Global.CHARACTERS.TAILS, #NONE
	Global.CHARACTERS.TAILS, #SONIC
	Global.CHARACTERS.SONIC, #TAILS
	Global.CHARACTERS.SONIC, #KNUCKLES
	Global.CHARACTERS.TAILS, #AMY
	Global.CHARACTERS.TAILS, #MIGHTY
	Global.CHARACTERS.TAILS, #RAY or other
]

func _ready() -> void:
	if startDirection == 0:
		startDirection = -1
	UpdateDirection(startDirection)
	
	# Decide Pilot based on Pilot type, if applicable
	if pilotType == 1:
		pilot = Global.PlayerChar1
	if pilotType == 2:
		pilot = Global.PlayerChar2
	if pilotType == 3:
		pilot = inheritedPilots[min(Global.PlayerChar1,inheritedPilots.size())]
	
	SetPilot()




func UpdateDirection(dir):
	$TornadoMain.scale.x = dir

func SetPilot():
	match pilot:
		Global.CHARACTERS.NONE:
			$TornadoMain/Pilot/PilotSonic.visible = false
			$TornadoMain/Pilot/PilotTails.visible = false
		Global.CHARACTERS.SONIC:
			$TornadoMain/Pilot/PilotSonic.visible = true
			$TornadoMain/Pilot/PilotTails.visible = false
		Global.CHARACTERS.TAILS:
			$TornadoMain/Pilot/PilotSonic.visible = false
			$TornadoMain/Pilot/PilotTails.visible = true
		_:
			$TornadoMain/Pilot/PilotSonic.visible = false
			$TornadoMain/Pilot/PilotTails.visible = true
