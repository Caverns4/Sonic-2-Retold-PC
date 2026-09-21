extends BossBase

# you can use these to control behaviour
var phase: int = 0
var phase_timer: float = 0

@onready var getPose: Array[Vector2] = [$TopPoint.global_position,$BottomPoint.global_position]
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

func _physics_process(delta: float) -> void:
	if !active: return
	# boss phase
	match(phase):
		0: # intro
			if global_position.y > getPose[0].y:
				velocity.y += -1
			else:
				global_position.y = getPose[0].y
				do_laugh()
				velocity = Vector2.ZERO
				hp = 8
				phase_timer = 3.0
				phase = 1
			move_and_slide()
		1:
			if hp > 0:
				global_position.y = move_toward(global_position.y,getPose[0].y,delta*60)
			phase_timer -= delta
			if phase_timer <= 0.0:
				phase_timer = 3.0
				phase = 2
		2:
			if hp > 0:
				global_position.y = move_toward(global_position.y,getPose[1].y,delta*60)
			phase_timer -= delta
			if phase_timer <= 0.0:
				phase_timer = 3.0
				phase = 1
		8: # Awaiting Escaping phase.
			run_escape_sequence(delta)
		9:
			pass
	updateHoveringPos(delta)
	super(delta)

func start_defeated_phase() -> void:
	set_animation("move")
	phase = 8
	await super()

var escape_phase_time: float = 3.0

func run_escape_sequence(delta:float = 0.0) -> void:
	if !defeated_flag: return
	escape_phase_time -= delta
	if velocity.y < 200: velocity.y += 100*delta
	if escape_phase_time <= 0.0:
		phase = 9
		queue_free()
	move_and_slide()
