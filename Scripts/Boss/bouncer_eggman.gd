extends BossBase

var deathTimer = 4
var dead = false

# you can use these to control behaviour
var phase = 0
var attackTimer = 0

@onready var eggpod_controller: Node2D = $EggpodController
@onready var bulletpoint: = $EggMobile/Eggmobile_Laser
@onready var getPose = [
	$LeftPoint.global_position,
	$RightPoint.global_position,
	$LeftPoint.global_position,
	$RightPoint.global_position,
	$TopPoint.global_position
	]
var currentPoint = 4
var laser_y: float = 128

var animationPriority = ["default","move","laugh","hit","exploded"]
var laser: = preload("res://Entities/Boss/Bouncer Eggman/bouncer_eggman_laser.tscn")

func _ready():
	# move to the set currentPoint position before the boss starts (plus 128 pixels higher)
	global_position = getPose[currentPoint]+Vector2(0,-1)*160
	# run laugh function for every time the player gets hit
	connect("hit_player",Callable(self,"do_laugh"))
	connect("got_hit",Callable(self,"panic"))
	super()

func _process(delta):
	# flame jet (only visible when moving)
	$EggMobile/EggmobileFlame.visible = !(velocity.x == 0 or $EggMobile/EggmobileFlame.visible)
	
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
					velocity.y = 200
			# if above 0.5 seconds left, move the momentum upwards until it's about -200
			elif deathTimer > 0.5:
				if velocity.y > -200:
					velocity.y -= 400*delta
				
				# if the next step is going to be below 0.5 seconds then stop moving
				if deathTimer-delta <= 0.5:
					velocity.y = 0
			
			# start running away once timer hits 0
			if deathTimer <= 0:
				velocity = Vector2(200,-25)
				scale.x = -abs(scale.x)
				emit_signal("boss_over")

func _physics_process(delta):
	super(delta)
	# move boss
	global_position += velocity*delta
	# check if alive
	if active and !dead:
		# boss phase
		match(phase):
			0: # intro
				if global_position.y < getPose[currentPoint].y:
					velocity = ((getPose[currentPoint]-global_position)*60).limit_length(64)
				# move to center between positions
				elif global_position.x > (getPose[0].lerp(getPose[1],0.5)).x:
					velocity = ((getPose[0].lerp(getPose[1],0.5)-global_position)*60).limit_length(64)
				elif attackTimer < 2:
					# do laugh
					if flashTimer <= 0:
						set_animation("laugh")
					velocity = Vector2.ZERO
					attackTimer += delta
				else: # end intro
					phase = 1
					currentPoint = 0
				
			1: # main attack
				if !eggpod_controller.children:
					phase = 3
					currentPoint = posmod(currentPoint+1,2)
					print("Final Phase")
				
				# reset hover position
				updateHoveringPos(delta)
				
				# set scale to face the current point position
				if velocity.x:
					scale.x = 0-sign(velocity.x)
				
				var target_position = getPose[currentPoint]
				if global_position.distance_to(target_position) > 2.0:
					var direction = (target_position - global_position).normalized()
					velocity = direction * 60
				else:
					velocity = Vector2.ZERO # Stop when close enough to the target
					if currentPoint < 4:
						currentPoint = posmod(currentPoint+1,getPose.size())
					else:
						attackTimer += delta
						
						if attackTimer <3.0:
							eggpod_controller.target_radius = 128
							eggpod_controller.target_speed = 4.0
						
						if attackTimer > 3.0:
							eggpod_controller.target_radius = 32
							eggpod_controller.target_speed = 3.0
							
						if attackTimer > 5.0:
							currentPoint = posmod(currentPoint+1,getPose.size())
							attackTimer = 0
				
				
				
			2: # Flee to the top position until no decoys are loose.
				# reset hover position
				updateHoveringPos(delta)
				
				var target_position = getPose[4] - Vector2(0,64)
				if global_position.distance_to(target_position) > 2.0:
					var direction = (target_position - global_position).normalized()
					velocity = direction * 120
				else:
					velocity = Vector2.ZERO 

				if !eggpod_controller.decoys:
					phase = 1
					currentPoint = 0
			3: #Out of Children
				# reset hover position
				updateHoveringPos(delta)
				var target_position = getPose[currentPoint] - Vector2(0,laser_y)
				if global_position.distance_to(target_position) > 2.0:
					var direction = (target_position - global_position).normalized()
					velocity = direction * 120
				else:
					velocity = Vector2.ZERO 
					scale.x = 0-sign(Global.players[0].global_position.x-global_position.x)
					attackTimer += delta
					if attackTimer > 0.5:
						laser_y -= 32
						fire_laser()
						attackTimer = 0.0
						#await get_tree().create_timer(1.0).timeout
					if laser_y < 0:
						laser_y = 96
						currentPoint = wrapi(currentPoint+1,0,2)


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

# Updated to allow precise calculate per-frame(hopefully)
func updateHoveringPos(delta):
	# change the hover offset
	global_position.y = global_position.y-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	call_deferred("restore_hover_pose")

func restore_hover_pose():
	global_position.y = global_position.y+hoverOffset

func fire_laser():
	var bullet = laser.instantiate()
	bullet.global_position = bulletpoint.global_position
	bullet.speed *= scale.x
	get_parent().add_child(bullet)
	pass



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

# boss defeated
func _on_boss_defeated():
	# set dead to true
	dead = true
	# hit animation for 1.5 seconds (see the dead section in _process)
	set_animation("hit",1.5)
	# set velocity to 0 to prevent moving
	velocity = Vector2.ZERO
	# star the smoke timer
	$SmokeTimer.start(0.01667*7)

# do a laugh for 1 second
func do_laugh():
	set_animation("laugh",1)

func panic():
	if phase == 1 and hp > 0 and eggpod_controller.children:
		phase = 2
		velocity = Vector2.ZERO

func _on_SmokeTimer_timeout():
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
