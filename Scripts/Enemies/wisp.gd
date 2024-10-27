extends EnemyBase

@onready var onscreen = $VisibleOnScreenNotifier2D
enum STATES{MAIN,WAIT,CIRCLE,FLEE}

var state = 0
var direction = -1
var stateTimer = 16/60.0
var stateCounter = 4

func _physics_process(delta: float) -> void:
	match state:
		STATES.MAIN:
			if onscreen.is_on_screen():
				state = STATES.WAIT
		STATES.WAIT:
			stateTimer -= delta
			if stateTimer < 0.0:
				stateCounter-=1
				if stateCounter >= 0:
					state = STATES.CIRCLE
					velocity.y = -60
					stateTimer = 96/60.0
				else:
					state = STATES.FLEE
					direction = -1
					velocity = Vector2(-120,-120)
		STATES.CIRCLE:
			stateTimer -= delta
			if stateTimer < 0.0:
				state = STATES.WAIT
				var temp = randi_range(0,32)
				stateTimer = temp/60.0
				velocity = Vector2.ZERO
			else:
				var target = GetClosestPlayer()
				var temp = global_position-target
				direction = 0-sign(temp.x)
				if direction == 0: direction = -1
				velocity.x += 0-sign(temp.x)*4
				velocity.y += 0-sign(temp.y)*4
				
				velocity.x = clampf(velocity.x,-120,120)
				velocity.y = clampf(velocity.y,-120,120)
		STATES.FLEE:
			if !onscreen.is_on_screen():
				queue_free()
	$AnimatedSprite2D.scale.x = 0-direction

func GetClosestPlayer():
	var vec = Vector2.ZERO
	var result = 1024
	for i in Global.players.size():
		var j = global_position.distance_to(Global.players[i].global_position)
		if j < result:
			result = j
			vec = Global.players[i].global_position
	return vec
