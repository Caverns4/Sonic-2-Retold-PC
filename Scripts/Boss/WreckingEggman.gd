extends BossBase

# you can use these to control behaviour
var phase: int = 0
var attackTimer: float = 0

@onready var getPose: Array[Vector2] = [$LeftPoint.global_position,$RightPoint.global_position]
var currentPoint: int = 1

@onready var wrecking_ball: Node2D = $BallAndChain

func boss_start(value: bool) -> void:
	active = value

func _ready() -> void:
	# move to the set currentPoint position before the boss starts (plus 128 pixels higher)
	global_position = getPose[currentPoint]+Vector2(0,-1)*128
	# run laugh function for every time the player gets hit
	connect("hit_player",Callable(self,"do_laugh"))
	if wrecking_ball:
		wrecking_ball.top_level = true
		wrecking_ball.set_hazard_collsions(false)
		wrecking_ball.active = false
		wrecking_ball.hazard.visible = false
	super()

func _process(delta: float) -> void:
	# flame jet (only visible when moving)
	$EggMobile/EggmobileFlame.visible = !(velocity.x == 0 or $EggMobile/EggmobileFlame.visible)
	update_flashing(delta)
	if wrecking_ball: wrecking_ball.position = global_position + Vector2(0,24)


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
				_mark_defeated()

func _physics_process(delta: float) -> void:
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
				else: # end intro
					if vulnerable: set_animation("laugh")
					velocity = Vector2.ZERO
					phase = 1
					currentPoint = 0
					if wrecking_ball:
						wrecking_ball.hazard.visible = true
						wrecking_ball.set_hazard_collsions(true)
			1: # Descend the ball and chain
				if attackTimer < 2:
					# do laugh
					attackTimer += delta
				if wrecking_ball and wrecking_ball.chain_size < 16:
					wrecking_ball.chain_size = move_toward(wrecking_ball.chain_size,16,delta*16)
				else:
					phase = 2
					currentPoint = 0
					if wrecking_ball:
						wrecking_ball.active = true
			2: # main attack
				
				# reset hover position
				global_position.y = global_position.y-hoverOffset
				# change the hover
				hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
				# move
				var getPosition: Vector2 = (getPose[currentPoint]-global_position)*60
				velocity = getPosition.limit_length(64)
				# now move the hover position back
				global_position.y = global_position.y+hoverOffset
				
				# set scale to face the current point position
				if is_equal_approx(global_position.x,getPose[currentPoint].x):
					scale.x = abs(scale.x)*remap(currentPoint,0,1,-1,1)
				
				# increase attack timer
				attackTimer += delta
				
				# switch positions after 5 seconds
				if attackTimer >= 3:
					currentPoint = 1-currentPoint
					attackTimer = 0

# boss defeated
func on_first_defeat() -> void:
	defeated_flag = true
	set_animation("hit",1.5)
	velocity = Vector2.ZERO
	smoke_timer.start(0.01667*7)
	if wrecking_ball:
		wrecking_ball.active = false
		wrecking_ball.set_hazard_collsions(false)
		await get_tree().create_timer(1.0).timeout
		wrecking_ball.destroy_chan_and_hazard()
		wrecking_ball = null
