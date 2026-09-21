extends BossBase

@export var entrySound: AudioStream = preload("res://Audio/SFX/Boss/s2br_helicopter.wav")

# you can use these to control behaviour
var phase: int = 0
var phase_timer: float = 0

@onready var getPose: Array[Vector2] = [$LeftPoint.global_position,$RightPoint.global_position]
var currentPoint: int = 1

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

func _process(delta: float) -> void:
	updateDirection()
	update_flashing(delta)

func _physics_process(delta: float) -> void:
	if !active: return
	# boss phase
	match(phase):
		0: # intro
			await run_intro_state(delta)
			move_and_slide()
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
	if !defeated_flag: return
	escape_phase_time -= delta
	if escape_phase_time > 0.5:
		if velocity.y > -180: velocity.y -= delta*30
		move_and_slide()
	elif escape_phase_time <= 0.0:
		phase = 9
		velocity = Vector2(300,-20)
		direction = 1
		eggman_face.stop()

func run_escape_2(delta: float) -> void:
	if global_position.x < getPose[1].x + 640:
		play_intro(delta)
		if velocity.x > 360: velocity.x += delta*100
	else:
		queue_free()
	move_and_slide()

func _boss_hit() -> void:
	super()
	if hp <=1 and drillCar:
		drillCar.readyToLaunch = true

func on_first_defeat() -> void:
	super()
	if drillCar: drillCar.die()

func start_defeated_phase() -> void:
	set_animation("move")
	z_index = 3
	$EggMobile/EggmobileFlame.visible = !(velocity.x == 0 or $EggMobile/EggmobileFlame.visible)
	phase = 8
	topAnimator.play("SPIN")
	await super()


func play_intro(delta: float) -> void:
	phase_timer -= delta
	if phase_timer <= 0.0:
		SoundDriver.play_sound(entrySound)
		phase_timer = 0.3

func _on_drill_eggman_car_car_touched() -> void:
	if !defeated_flag:
		readyEnterCar = true
