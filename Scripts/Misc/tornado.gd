class_name Tornado2D
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
## The sound effect when the plane is damaged.
@export var boom_sfx = preload("res://Audio/SFX/Boss/s2br_SmallExplosion.wav")

## Scene instantiated when the Tornado is on a timer.
var explosion = preload("res://Entities/Misc/GenericParticle.tscn")

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
var explosion_timer: float = 0.0

signal plane_damaged

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

func _physics_process(delta: float) -> void:
	if explosion_timer:
		explosion_timer -= delta
		if explosion_timer < 0.6:
			var this: AnimatedSprite2D = explosion.instantiate()
			this.play("Explosion")
			this.global_position = global_position - Vector2(0,40)
			this.z_index = 30
			this.top_level = true
			get_parent().get_parent().add_child(this)
			if $VisibleOnScreenNotifier2D.is_on_screen():
				SoundDriver.play_sound2(boom_sfx)
			explosion_timer = 1.0
	move_and_slide()



func _on_player_sensor_body_entered(body: Node2D) -> void:
	if body is Player2D:
		standing_players.append(body)


func _on_player_sensor_body_exited(body: Node2D) -> void:
	if body is Player2D:
		standing_players.erase(body)

func _damage_plane():
	if !explosion_timer:
		plane_damaged.emit()
		explosion_timer = 0.6
		velocity.y = 60.0
		$CollisionShape2D.disabled = true
