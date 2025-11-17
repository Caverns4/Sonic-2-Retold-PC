extends BossBase

var deathTimer = 4
var dead = false

# you can use these to control behaviour
var phase = 0
var soundTimer = 0.0

@onready var getPose = [$TopPoint.global_position,$BottomPoint.global_position]
var currentPoint = 1

var direction = -1 #left is -1, right is 1

var animationPriority = ["default","move","laugh","hit","exploded"]

var targetPosition = Vector2.ZERO

func _ready():
	# move to the set currentPoint position before the boss starts (plus 128 pixels higher)
	global_position = getPose[currentPoint]
	# run laugh function for every time the player gets hit
	connect("hit_player",Callable(self,"do_laugh"))
	super()

func _process(delta):
	updateDirection()
	
	# flashing for the egg mobile 
	if flashTimer > 0:
		$EggMobile/EggFlash.visible = !$EggMobile/EggFlash.visible
	else:
		$EggMobile/EggFlash.visible = false
	
	# dead animation timer (default time is 3 seconds)
	if dead:
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
				emit_signal("boss_over")

func _physics_process(delta):
	# move boss
	global_position += velocity*delta
	# check if alive
	if active and !dead:
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
		# check if dead, this can cause a conflict where the idle animation would play when it shouldn't
		elif !dead:
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

# do a laugh for 1 second
func do_laugh():
	set_animation("laugh",1)

func _on_smoke_timer_timeout() -> void:
	# check that deathtimer's still going and that we are actually dead
	if dead and deathTimer > 1.5:
		# play explosion sound
		$Explode.play()
		# spawn exposion particles
		var expl = Explosion.instantiate()
		# set animation
		expl.play("BossExplosion")
		expl.z_index = 10
		# add object
		get_parent().add_child(expl)
		# set position reletive to us
		expl.global_position = global_position+Vector2(randf_range(-32,32),randf_range(-32,32))


func _on_defeated() -> void:
	# set dead to true
	dead = true
	# hit animation for 1.5 seconds (see the dead section in _process)
	set_animation("hit",1.5)
	# set velocity to 0 to prevent moving
	velocity = Vector2.ZERO
	# star the smoke timer
	$SmokeTimer.start(0.01667*7)
