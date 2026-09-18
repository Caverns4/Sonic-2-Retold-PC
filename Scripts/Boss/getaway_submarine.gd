extends BossBase

# you can use these to control behaviour
var phase: int = 0

@onready var getPose = [$TopPoint.global_position,$BottomPoint.global_position]
var currentPoint: int = 1

var targetPosition: Vector2 = Vector2.ZERO

func _ready() -> void:
	# move to the set currentPoint position before the boss starts (plus 128 pixels higher)
	global_position = getPose[currentPoint]
	# run laugh function for every time the player gets hit
	connect("hit_player",Callable(self,"do_laugh"))
	super()

func _process(delta: float) -> void:
	updateDirection()
	update_flashing(delta)


func scrap(delta:float = 0.0) -> void:
	var deathTimer: float = 0.0
	# defeated animation timer (default time is 3 seconds)
	if defeated_flag:
		# if above 0 then count down
		if deathTimer > 0:
			# count down
			deathTimer -= delta
			# if about to hit 1.5 seconds, set velocity downward
			if deathTimer > 1.5:
				if deathTimer-delta <= 1.5:
					set_animation("exploded",1.5)
					#velocity.y = 200
			# if above 0.5 seconds left, move the momentum upwards until it's about -200
			elif deathTimer > 0.5:
				if velocity.y < 200:
					velocity.y += 100*delta
			
			# start running away once timer hits 0
			if deathTimer <= 0:
				#scale.x = -abs(scale.x)
				_mark_defeated()

func _physics_process(delta: float) -> void:
	# move boss
	global_position += velocity*delta
	# check if alive
	if active and !defeated_flag:
		# boss phase
		match(phase):
			0: # intro
				if global_position.y > getPose[0].y:
					velocity.y += -1
				else:
					global_position.y = getPose[0].y
					set_animation("laugh") #laugh
					velocity = Vector2.ZERO
					hp = 8
					phase = 1
			_: # Controlled by external object.
				pass
	
	updateHoveringPos(delta)
	super(delta)
