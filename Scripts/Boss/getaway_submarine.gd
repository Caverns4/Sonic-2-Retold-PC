extends BossBase

# you can use these to control behaviour
var phase = 0
var soundTimer = 0.0

@onready var getPose = [$TopPoint.global_position,$BottomPoint.global_position]
var currentPoint = 1

var direction = -1 #left is -1, right is 1

var targetPosition = Vector2.ZERO

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

func _physics_process(delta):
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
	# default reactions (use animation time to avoid running this every frame)
	if $AnimationTime.is_stopped():
		# if moving, then run move animation
		if velocity.x != 0:
			set_animation("move")
		elif !defeated_flag:
			set_animation("default")
	# only run hit if flash timer is above 0
	if flashTimer > 0:
		set_animation("hit",flashTimer)
	

func updateHoveringPos(delta):
	# change the hover offset
	global_position.y = global_position.y-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	global_position.y = global_position.y+hoverOffset


# animation to play, time is how long the animation should play for until it stops
func set_animation(animation = "default", time = 0.0):
	# check that the animation exists in the animationPriority list
	if animationPriority.has(animation):
		# if the animation exists then compare the position
		var animID = animationPriority.find(animation)
		var currentAnimID = animationPriority.find($EggMobile/Robotnik.animation)
		
		# if the new animation ID is higher then the current one or the animation time isn't running then play the animation
		if animID > currentAnimID or $AnimationTime.is_stopped():
			$EggMobile/Robotnik.play(animation)
			$AnimationTime.start(time)
	# if there is no priority set then just run the new animation
	else:
		$EggMobile/Robotnik.play(animation)
		$AnimationTime.start(time)

func updateDirection():
	if direction > 0:
		$EggMobile.scale.x = -1
	else:
		$EggMobile.scale.x = 1


func on_first_defeat() -> void:
	defeated_flag = true
	set_animation("hit",1.5)
	velocity = Vector2.ZERO
	$SmokeTimer.start(0.01667*7)
