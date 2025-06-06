extends Area2D

@export var minimum_speed = 120

var players: Array[Player2D] = []

func _physics_process(delta: float) -> void:
	for player in players:
		if player.ground and abs(player.movement.x) < minimum_speed and !player.controlObject:
			player.movement.x = minimum_speed*sign(player.movement.x)
			if player.movement.x == 0:
				player.movement.x = player.direction.x *minimum_speed
			player.movement.x += (12 * sign(player.movement.x))


func _on_body_entered(body: Node2D) -> void:
	players.append(body)


func _on_body_exited(body: Node2D) -> void:
	players.erase(body)
