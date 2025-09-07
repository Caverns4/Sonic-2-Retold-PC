extends AnimatableBody2D

@onready var floorCheck = $RayCast2D

var gravity = false
var srpingPlayers = false
var movement = Vector2.ZERO
var worldPos = Vector2.ZERO
var players = []

func  _ready() -> void:
	worldPos = Vector2(round(global_position.x),round(global_position.y))

func _physics_process(delta: float) -> void:
	if gravity:
		movement.y += 9.8*delta
	
	worldPos += movement
	global_position = round(worldPos)

func physics_collision(body, hitVector):
	if hitVector.y > 0 and body.ground and srpingPlayers:
		players.append(body)
		body.set_state(body.STATES.AIR)
		body.movement.y = -1000
		players.erase(body)
