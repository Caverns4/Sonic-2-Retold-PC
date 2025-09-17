extends Node2D

@export var max_launch_power = 24
@export var min_launch_power = 4

@export var sfx = preload("res://Audio/SFX/Objects/CNZ_Booster.wav")

var players: Array[Player2D] = []
var charge_time: float = 0.0
var ready_to_fire: bool = false

@onready var spring_cap = $Area2D
@onready var spring_coils = $SpringCoils

func  _process(delta: float) -> void:
	for body in players:
		body.global_position = $Area2D.global_position
	_update_spring()

func _physics_process(delta: float) -> void:
	for body in players:
		if body.any_action_held() and body.playerControl > 0:
			ready_to_fire = true
	
	if !ready_to_fire:
		return
	else:
		charge_time += delta*(max_launch_power/min_launch_power)
		#print(charge_time)
		for body in players:
			if body.any_action_held() and body.playerControl > 0:
				return
		#Launch
		ready_to_fire = false
		SoundDriver.play_sound2(sfx)
		for body in players:
			body.set_state(body.STATES.ROLL,body.currentHitbox.ROLL)
			body.allowTranslate = false
			body.ground = true
			body.angle = global_rotation_degrees
			var clamp = clampf(charge_time,abs(min_launch_power),abs(max_launch_power))
			body.movement = (Vector2.UP * clamp*60).rotated(global_rotation)
		charge_time = 0.0
		players.clear()


func _update_spring():
	spring_cap.position.y = -64 + min(charge_time,24)
	spring_coils.position.y = spring_cap.position.y/2
	#spring_coils.size.y = abs(spring_cap.position.y)/2

func _on_area_2d_body_entered(body: Player2D) -> void:
	players.append(body)
	body.allowTranslate = true
	body.movement = Vector2.ZERO
	body.animator.play("roll")
	body.set_state(body.STATES.ANIMATION,body.currentHitbox.ROLL)
