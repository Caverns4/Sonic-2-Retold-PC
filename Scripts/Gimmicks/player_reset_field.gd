extends Area2D

#Reset the properties of any Player entering this field

func _on_body_entered(body: Node2D) -> void:
	if Global.players.has(body):
		var node = Global.players[Global.players.find(body)]
		node.set_state(body.STATES.AIR)
		node.controlObject = null
		node.global_position = global_position
		node.translate = false
