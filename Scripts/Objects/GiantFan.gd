extends Area2D


var players: Array[Player2D] = []

func _process(_delta: float)->void:
	for i: Player2D in players:
		if i.collissionLayer == 0:
			i.movement.y = (global_position.y-96 - i.global_position.y) * 6.0
			if i.ground:
				i.disconect_from_floor()
				i.animator.play("current")

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		players.append(body)
		body.animator.play("current")
		body.abilityUsed = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player2D:
		players.erase(body)
