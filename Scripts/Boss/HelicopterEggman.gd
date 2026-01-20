extends BossBase

@export var entrySound = preload("res://Audio/SFX/Boss/s2br_helicopter.wav")

# you can use these to control behaviour
var phase = 0
var soundTimer = 0.0

@onready var getPose = [$LeftPoint.global_position,$RightPoint.global_position]
var currentPoint = 1

var direction = -1 #left is -1, right is 1

var animationPriority = ["default","move","laugh","hit","exploded"]

@onready var topAnimator = $Helicopter
var drillCar = null #Node
var readyEnterCar = false
var targetPosition = Vector2.ZERO

func _ready():
	# move to the set currentPoint position before the boss starts (plus 128 pixels higher)
	global_position = getPose[currentPoint]
	# run laugh function for every time the player gets hit
	connect("hit_player",Callable(self,"do_laugh"))
	drillCar = get_tree().get_root().find_child("DrillEggmanCar",true,false)
	if drillCar:
		drillCar.connect("carTouched",Callable(self,"_on_drill_eggman_car_car_position"))
	hp = 255 #Can't kill Eggman til he lands, but can damage him for fun
	super()

func _process(delta):
	updateDirection()
	
	# flashing for the egg mobile 
	if flashTimer > 0:
		$EggMobile/EggFlash.visible = !$EggMobile/EggFlash.visible
	else:
		$EggMobile/EggFlash.visible = false
	
	# defeated animation timer (default time is 3 seconds)
	if defeated_flag:
		# flame jet (only visible when moving)
		$EggMobile/EggmobileFlame.visible = !(velocity.x == 0 or $EggMobile/EggmobileFlame.visible)
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
				if velocity.y > -200:
					velocity.y -= 100*delta
				# if the next step is going to be below 0.5 seconds then stop moving
				if deathTimer-delta <= 0.5:
					velocity.y = 0
			
			# start running away once timer hits 0
			if deathTimer <= 0:
				velocity = Vector2(200,-25)
				direction = 1
				_mark_defeated()

func _physics_process(delta):
	# move boss
	global_position += velocity*delta
	# check if alive
	if active and !defeated_flag and drillCar:
		# boss phase
		match(phase):
			0: # intro
				# move to center between positions
				if global_position.x > (getPose[0].lerp(getPose[1],0.5)).x and !readyEnterCar:
					velocity = ((getPose[0].lerp(getPose[1],0.5)-global_position)*60).limit_length(64)
					velocity.y = 18.0
					play_intro(delta)
				elif readyEnterCar and global_position.y < targetPosition.y:
					velocity.x = 0.0
					velocity.y = 20.0
				elif readyEnterCar and global_position.y > targetPosition.y:
					global_position = targetPosition
					topAnimator.play("CLOSE")
					#if flashTimer <= 0:
					set_animation("laugh") #laugh
					velocity = Vector2.ZERO
					
					await get_tree().create_timer(0.25).timeout
					hp = 8
					phase = 1
					if Global.hud:
						Global.hud.setup_boss_meter(self)
					drillCar.pilot = true
					drillCar.playMotor()
			_: # Controlled by external object.
				if hp <= 1:
					drillCar.readyToLaunch = true
					
	super(delta)
	# default reactions (use animation time to avoid running this every frame)
	if $AnimationTime.is_stopped():
		# if moving, then run move animation
		if velocity.x != 0:
			set_animation("move")
		# check if defeated_flag, this can cause a conflict where the idle animation would play when it shouldn't
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

# boss defeated
func _on_boss_defeated():
	defeated_flag = true
	if drillCar:
		drillCar.die()
	set_animation("hit",1.5)
	velocity = Vector2.ZERO
	$SmokeTimer.start(0.01667*7)

# do a laugh for 1 second
func do_laugh():
	set_animation("laugh",1)

func play_intro(delta):
	soundTimer -= delta
	if soundTimer <= 0.0:
		SoundDriver.play_sound(entrySound)
		soundTimer = 0.3

func _on_SmokeTimer_timeout():
	# check that deathtimer's still going and that we are actually defeated.
	if defeated_flag and deathTimer > 1.5:
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


func _on_drill_eggman_car_car_touched():
	if !defeated_flag:
		readyEnterCar = true
