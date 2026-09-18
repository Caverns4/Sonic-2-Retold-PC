extends BossBase

# you can use these to control behaviour
var phase = 0
var attackTimer = 0

@onready var eggpod_controller: Node2D = $EggpodController
@onready var bulletpoint: = $EggMobile/Eggmobile_Laser
@onready var getPose: Array[Vector2] = [
	$LeftPoint.global_position,
	$RightPoint.global_position,
	$LeftPoint.global_position,
	$RightPoint.global_position,
	$TopPoint.global_position
	]
var currentPoint: int = 4
var laser_y: float = 128

var laser: = preload("res://Entities/Boss/Bouncer Eggman/bouncer_eggman_laser.tscn")

func _ready() -> void:
	# move to the set currentPoint position before the boss starts (plus 128 pixels higher)
	global_position = getPose[currentPoint]+Vector2(0,-1)*160
	# run laugh function for every time the player gets hit
	connect("hit_player",Callable(self,"do_laugh"))
	connect("got_hit",Callable(self,"panic"))
	super()

func _process(delta: float) -> void:
	# flame jet (only visible when moving)
	$EggMobile/EggmobileFlame.visible = !(velocity.x == 0 or $EggMobile/EggmobileFlame.visible)
	update_flashing(delta)


func scrap(delta:float = 0.0) -> void:
	var deathTimer: float = 0.0
	# defeated animation timer (default time is 3 seconds)
	if defeated_flag and deathTimer > 0:
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
		elif deathTimer <= 0:
			velocity = Vector2(200,-25)
			scale.x = -abs(scale.x)
			_mark_defeated()

func _physics_process(delta):
	super(delta)
	# move boss
	global_position += velocity*delta
	# check if alive
	if active and !defeated_flag:
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
					if vulnerable:
						do_laugh()
					velocity = Vector2.ZERO
					attackTimer += delta
				else: # end intro
					phase = 1
					currentPoint = 0
				
			1: # main attack
				if !eggpod_controller.children and !eggpod_controller.decoys:
					phase = 3
					currentPoint = posmod(currentPoint+1,2)
				
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
						elif attackTimer > 3.0:
							eggpod_controller.target_radius = 16
							eggpod_controller.target_speed = 2.0
						if attackTimer > 6.0:
							currentPoint = posmod(currentPoint+1,getPose.size())
							eggpod_controller.target_radius = 48
							eggpod_controller.target_speed = 3.0
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
					currentPoint = wrapi(currentPoint,0,1)
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

func fire_laser():
	var bullet = laser.instantiate()
	bullet.global_position = bulletpoint.global_position
	bullet.speed *= scale.x
	get_parent().add_child(bullet)

func panic():
	if phase == 1 and hp > 0 and eggpod_controller.children:
		phase = 2
		velocity = Vector2.ZERO
