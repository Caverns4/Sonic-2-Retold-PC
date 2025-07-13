extends Node2D

@export_enum("up","right","down","left") var startDirection = 0

var players = []
var sfx = preload("res://Audio/SFX/Player/s2br_Roll.wav")
var directionNames =["Up","Right","Down","Left"]
var launchDir = startDirection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	launchDir = startDirection

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for player in players:
		if player.controlObject != self:
			players.erase(player)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var LaunchPlayerDirection = Vector2.UP.rotated(deg_to_rad(launchDir*90))
	
	if Global.players.has(body):
		players.append(body)
		var node = Global.players[Global.players.find(body)]
		node.controlObject = self
		node.movement = Vector2.ZERO
		node.global_position = global_position
		node.allowTranslate = true
		node.movement = LaunchPlayerDirection * 800
		SoundDriver.play_sound(sfx)
		node.set_state(body.STATES.ANIMATION)
		node.animator.play("roll")

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
