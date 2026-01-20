extends StaticBody2D

const DOWN_TIME = 1.0/30.0

var players = []
var direction = 0
var WeightVal = 0.0
var downTimer = 0.0

var lauchSpeeds = [0, 1,  1,  2,  2,  3,  3,  3,  4]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = sign(scale.rotated(rotation).x)#clampf(global_scale.x,-1,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	downTimer -= delta
	
	if downTimer <= 0.0 and $Sprite2D.frame != 0:
		$Sprite2D.frame = 0
		$SpringSound.play()
		SpringCharacters()
		players = []
	
	if $Sprite2D.frame != 0:
		$CollisionPolygon2D.scale.y = 0.4
	else:
		$CollisionPolygon2D.scale.y = 1.0

func physics_collision(body, hitVector):
	#If player(s) are standing on the objects, detect the furthest one out.
	if hitVector.y > 0.0:
		players.append(body)
		if downTimer <= 0.0:
			var temp = max(abs(direction * (body.global_position.x - global_position.x)),0)
			temp -= (16*direction)
			if temp > 0:
				downTimer = DOWN_TIME
				$Sprite2D.frame = 1

func SpringCharacters():
	for i in players.size():
		var node = players[i]
		var temp = round(abs((direction * (global_position.x - node.global_position.x))-24)/8)
		temp = min(max(temp,0),lauchSpeeds.size()-1)
		var speedSet = (lauchSpeeds[temp]) * 60
		
		node.set_state(node.STATES.AIR)
		node.ground = false
		node.air_control = true
		node.animator.queue("walk")
		node.animator.play("corkScrew")
		
		node.movement.y = -240 - (speedSet)
		if abs(node.movement.x) > 360:
			speedSet *= direction
			node.movement.x -= speedSet
