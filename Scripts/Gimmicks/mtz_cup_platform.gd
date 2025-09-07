extends AnimatableBody2D

var players: Array[Player2D] = []
var last_x = 0

func _ready() -> void:
	last_x = global_position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.x != last_x:
		for i in players:
			if i.ground:
				i.global_position.x += (global_position.x-last_x)
	
	last_x = global_position.x


func _on_player_censor_body_entered(body: Node2D) -> void:
	players.append(body)


func _on_player_censor_body_exited(body: Node2D) -> void:
	players.erase(body)
