extends AnimatableBody2D

var gravity: bool = false
var srpingPlayers: bool = false
var movement: Vector2 = Vector2.ZERO
var worldPos: Vector2 = Vector2.ZERO
var players: Array[Player2D] = []

func  _ready() -> void:
	worldPos = Vector2(round(global_position.x),round(global_position.y))

func _physics_process(delta: float) -> void:
	if gravity:
		movement.y += 9.8*delta
	
	worldPos += movement
	global_position = round(worldPos)

func physics_collision(body: CharacterBody2D, hitVector: Vector2) -> void:
	if hitVector.y > 0 and body.ground and srpingPlayers:
		players.append(body)
		body.set_state(body.STATES.AIR)
		body.movement.y = -1000
		players.erase(body)
