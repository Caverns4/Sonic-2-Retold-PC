extends Node2D

var players: Array[Player2D] = []
var sfx = preload("res://Audio/SFX/Player/s2br_Roll.wav")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for player in players:
		if player.controlObject != self:
			players.erase(player)

func _on_area_2d_body_entered(body: Player2D) -> void:
	if Global.players.has(body):
		players.append(body)
		var node = Global.players[Global.players.find(body)]
		node.controlObject = self
		node.movement = Vector2.ZERO
		node.global_position = global_position
		node.allowTranslate = true
		node.movement = (Vector2.UP * 800).rotated(global_rotation)
		SoundDriver.play_sound(sfx)
		node.set_state(body.STATES.ANIMATION)
		node.animator.play("roll")
