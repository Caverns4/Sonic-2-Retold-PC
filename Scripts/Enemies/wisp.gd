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
				stateTimer = (randi_range(0,32))/60.0
				velocity = Vector2.ZERO
			else:
				var target = GlobalFunctions.get_orientation_to_player(global_position)
				direction = sign(target.x)
				if direction == 0: direction = -1
				velocity.x += sign(target.x)*4
				velocity.y += sign(target.y)*4
				
				velocity.x = clampf(velocity.x,-120,120)
				velocity.y = clampf(velocity.y,-120,120)
		STATES.FLEE:
			if !onscreen.is_on_screen():
				queue_free()
	$AnimatedSprite2D.scale.x = 0-direction
