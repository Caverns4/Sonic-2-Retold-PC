extends BossBase

@export var entrySound: AudioStream = preload("res://Audio/SFX/Boss/s2br_helicopter.wav")

# you can use these to control behaviour
var phase: int = 0
var soundTimer: float = 0.0

@onready var getPose: Array[Vector2] = [$LeftPoint.global_position,$RightPoint.global_position]
var currentPoint: int = 1

var direction: int = -1 #left is -1, right is 1

@onready var topAnimator: AnimationPlayer = $Helicopter
var drillCar: CharacterBody2D = null
var readyEnterCar: bool = false
var targetPosition: Vector2 = Vector2.ZERO

func _ready() -> void:
	super()
	# move to the set currentPoint position before the boss starts (plus 128 pixels higher)
	global_position = getPose[currentPoint]
	# run laugh function for every time the player gets hit
	connect("hit_player",Callable(self,"do_laugh"))
	drillCar = get_tree().get_root().find_child("DrillEggmanCar",true,false)
	if drillCar:
		drillCar.connect("carTouched",Callable(self,"_on_drill_eggman_car_car_position"))
	hp = 255 #Can't kill Eggman til he lands, but can damage him for fun

func _process(_delta: float) -> void:
	updateDirection()
	
	# flashing for the egg mobile 
	if !vulnerable and hp > 0:
		$EggMobile/EggFlash.visible = !$EggMobile/EggFlash.visible
	else:
		$EggMobile/EggFlash.visible = false

func _physics_process(delta: float) -> void:
	# move boss
	global_position += velocity*delta
	# check if alive
	if active:
		# boss phase
		match(phase):
			0: # intro
				await run_intro_state(delta)
			1: #car-controlled
				pass
			8: #escape
				run_escape_1(delta)
			9: #escape
				run_escape_2(delta)
			_: # Controlled by external object.
				if hp <= 1:
					drillCar.readyToLaunch = true
	super(delta)

func run_intro_state(delta: float) -> void:
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
		set_animation("laugh")
		velocity = Vector2.ZERO
		await get_tree().create_timer(0.25).timeout
		hp = 8
		if Global.hud: Global.hud.update_boss_meter_max(self)
		phase = 1
		drillCar.pilot = true
		drillCar.playMotor()

var escape_phase_time: float = 1.5

func run_escape_1(delta: float) -> void:
	escape_phase_time -= delta
	if escape_phase_time > 0.5:
		if velocity.y > -120: velocity.y -= delta*20
		move_and_slide()
	elif escape_phase_time <= 0.0:
		phase = 9
		velocity = Vector2(180,-25)
		direction = 1
		eggman_face.stop()
		set_animation("hit",0.0)

func run_escape_2(_delta: float) -> void:
	move_and_slide()

func _boss_hit() -> void:
	super()
	if hp <=1 and drillCar:
		drillCar.readyToLaunch = true

func updateHoveringPos(delta: float) -> void:
	# change the hover offset
	global_position.y = global_position.y-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	global_position.y = global_position.y+hoverOffset

func updateDirection() -> void:
	if direction > 0:
		$EggMobile.scale.x = -1
	else:
		$EggMobile.scale.x = 1

func _on_boss_defeated() -> void:
	super()
	if drillCar: drillCar.die()

func start_defeated_phase() -> void:
	defeated_flag = true
	z_index = 3
	$EggMobile/EggmobileFlame.visible = !(velocity.x == 0 or $EggMobile/EggmobileFlame.visible)
	phase = 8
	topAnimator.play("OPEN")
	await get_tree().create_timer(1.0).timeout
	_mark_defeated()


func play_intro(delta: float) -> void:
	soundTimer -= delta
	if soundTimer <= 0.0:
		SoundDriver.play_sound(entrySound)
		soundTimer = 0.3

func _on_drill_eggman_car_car_touched() -> void:
	if !defeated_flag:
		readyEnterCar = true
