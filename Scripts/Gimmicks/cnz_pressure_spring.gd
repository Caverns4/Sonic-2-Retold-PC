extends Node2D

var max_launch_power = 8

var charge_time: float = 0.0
var players: Array[Player2D] = []
var ready_to_fire: bool = false

@onready var spring_cap = $Area2D

func  _process(delta: float) -> void:
	for body in players:
		body.global_position = $Area2D.global_position
	_update_spring()

func _physics_process(delta: float) -> void:
	for body in players:
		if body.any_action_held():
			ready_to_fire = true
			charge_time += delta
	
	if !ready_to_fire:
		return
	else:
		for body in players:
			if body.any_action_held():
				return
		#Launch
		ready_to_fire = false
		for body in players:
			body.allowTranslate = false
			body.set_state(body.STATES.ROLL)
			body.movement = (Vector2.UP * charge_time*20*60).rotated(global_rotation)
			
			players.erase(body)
		charge_time = 0.0


func _update_spring():
	spring_cap.position.y = -64 + min(charge_time*20,32)

func _on_area_2d_body_entered(body: Player2D) -> void:
	players.append(body)
	body.allowTranslate = true
	body.movement = Vector2.ZERO
	body.set_state(body.STATES.ANIMATION)
