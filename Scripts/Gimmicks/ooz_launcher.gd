extends Node2D

@export_enum("up","right","down","left") var startDirection = 0
@export_enum("clockwise","counter-clockwise") var turnDirection = 0

var players = []
var sfx = preload("res://Audio/SFX/Player/s2br_Roll.wav")
var directionNames =["Up","Right","Down","Left"]
var launchDir = startDirection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetupLaunchDir()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for player in players:
		if player.controlObject != self:
			players.erase(player)


func SetupLaunchDir():
	launchDir = startDirection
	if turnDirection == 0:
		launchDir += 1
	else:
		launchDir -= 1
	launchDir = wrapi(launchDir,0,directionNames.size())
	
	var animName = (str(directionNames[launchDir]) + str(directionNames[startDirection]))
	$AnimatedSprite2D.play(animName)
	return launchDir


func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.players.has(body):
		players.append(body)
		var node = Global.players[Global.players.find(body)]
		node.controlObject = self
		node.set_state(body.STATES.ANIMATION)
		node.animator.play("Roll")
		node.movement = Vector2.ZERO
		node.global_position = global_position
		node.allowTranslate = true
		Global.play_sound(sfx)
		var animName = (str(directionNames[startDirection]) + str(directionNames[launchDir]))
		#print(animName)
		$AnimatedSprite2D.play(animName)



func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished() -> void:
	var LaunchPlayerDirection = Vector2.UP.rotated(deg_to_rad(launchDir*90))
	for i in players:
		i.movement = LaunchPlayerDirection * 800
		print(LaunchPlayerDirection)
