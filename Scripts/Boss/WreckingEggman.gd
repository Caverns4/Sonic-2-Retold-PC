extends BossBase

# you can use these to control behaviour
var phase: int = 0
var state_timer: float = 0

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

func _physics_process(delta: float) -> void:
	if !active: return
	super(delta)
	# boss phase
	match(phase):
		0: # Intro phase
			run_intro_phase(delta)
		1: # Descend the ball and chain
			drop_ball(delta)
		2: # Attack phase
			move_left_right(delta)
		8: # Escape phase
			if smoke_timer.is_stopped():
				scrap(delta)
	move_and_slide()

func run_intro_phase(_delta: float) -> void:
	if global_position.y < getPose[currentPoint].y:
		velocity = ((getPose[currentPoint]-global_position)*60).limit_length(64)
		# move to center between positions
	elif global_position.x > (getPose[0].lerp(getPose[1],0.5)).x:
		velocity = ((getPose[0].lerp(getPose[1],0.5)-global_position)*60).limit_length(64)
	else: # end intro
		if vulnerable: do_laugh()
		velocity = Vector2.ZERO
		phase = 1
		currentPoint = 0
		if wrecking_ball:
			wrecking_ball.hazard.visible = true
			wrecking_ball.set_hazard_collsions(true)

func drop_ball(delta: float) -> void:
	if state_timer < 2:
		state_timer += delta
	if wrecking_ball and wrecking_ball.chain_size < 16:
		wrecking_ball.chain_size = move_toward(wrecking_ball.chain_size,16,delta*16)
	else:
		phase = 2
		currentPoint = 0
		if wrecking_ball: wrecking_ball.active = true

func move_left_right(delta: float) -> void:
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
		direction = 0-roundi(remap(currentPoint,0,1,-1,1))
		updateDirection()
	# increase attack timer
	state_timer += delta
	# switch positions after 5 seconds
	if state_timer >= 3:
		currentPoint = 1-currentPoint
		state_timer = 0

func scrap(delta:float) -> void:
	state_timer -= delta
	# if about to hit 1.5 seconds, set velocity downward
	if state_timer > 1.5:
		if state_timer-delta <= 1.5:
			set_animation("exploded",1.5)
			velocity.y = 200
	# if above 0.5 seconds left, move the momentum upwards until it's about -200
	elif state_timer > 0.5:
		if velocity.y > -200:
			velocity.y -= 400*delta
		# if the next step is going to be below 0.5 seconds then stop moving
		if state_timer-delta <= 0.5:
			velocity.y = 0
			
	# start running away once timer hits 0
	if state_timer <= 0:
		velocity = Vector2(200,-25)
		scale.x = -abs(scale.x)



# boss defeated
func on_first_defeat() -> void:
	super()
	phase = 8
	if wrecking_ball:
		wrecking_ball.active = false
		wrecking_ball.set_hazard_collsions(false)
		await get_tree().create_timer(1.0).timeout
		wrecking_ball.destroy_chan_and_hazard()
		wrecking_ball = null

func start_defeated_phase() -> void:
	phase = 8
	state_timer = 0.0
	@warning_ignore("missing_await")
	super()
	_mark_defeated()
