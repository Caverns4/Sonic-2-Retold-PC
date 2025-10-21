extends CharacterBody2D

# This object doesn't do much on its own; It simply updates graphics. All controls are extrnal.

## Which Character should be shown as the pilot. If Inheret, the character will be dynamically chosen.
@export_enum("Static Character","Player 1","Player 2","Inheret") var pilotType = 0
## If Static Character is set, which Character.
@export var pilot: Global.CHARACTERS = Global.CHARACTERS.SONIC
## Which direction the Tornado should face.
@export_enum("Left","Right") var startDirection = 1
## If true, show the jet engine used to repair the Tornado.
@export var jet_engine: bool = false


var parenter_pilots = [
	Global.CHARACTERS.TAILS, #NONE
	Global.CHARACTERS.TAILS, #SONIC
	Global.CHARACTERS.SONIC, #TAILS
	Global.CHARACTERS.SONIC, #KNUCKLES
	Global.CHARACTERS.TAILS, #AMY
	Global.CHARACTERS.RAY,   #MIGHTY
	Global.CHARACTERS.MIGHTY, #RAY
]

var standing_players: Array[Player2D] = []

func _ready() -> void:
	if jet_engine:
		$TornadoMain/Jet.visible = true
	if startDirection == 0:
		startDirection = -1
	UpdateDirection(startDirection)
	
	# Decide Pilot based on Pilot type, if applicable
	if pilotType == 1:
		pilot = Global.PlayerChar1
	if pilotType == 2:
		pilot = Global.PlayerChar2
	if pilotType == 3:
		pilot = parenter_pilots[min(Global.PlayerChar1,parenter_pilots.size())]
	
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


func _on_player_sensor_body_entered(body: Node2D) -> void:
	if body is Player2D:
		standing_players.append(body)


func _on_player_sensor_body_exited(body: Node2D) -> void:
	if body is Player2D:
		standing_players.erase(body)
