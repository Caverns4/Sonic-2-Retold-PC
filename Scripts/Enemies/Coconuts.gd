extends EnemyBase

var Projectile: PackedScene = preload("res://Entities/Enemies/Projectiles/CoconutProjectile.tscn")
var coconut: Node2D = null

enum STATE{IDLE,CLIMB,THROW}
var state: STATE = STATE.IDLE

var climbTimes: Array[float] = [ #Values from Sonic 2. Divide by 60.0
	32,
	24,
	16,
	40,
	32,
	16
	]

var climbSpeeds: Array[int] = [1,-1] #y speeds
var climb_state: int = 0 #Which climbing routine to do
var timer_over: bool = false
var throw_nut: bool = false

var targets: Array[Player2D] = [] #Players in the PlayerCheckBody

@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
	$PlayerCheck.visible = true
	super()

func _process(delta: float) -> void:
	match state:
		STATE.IDLE:
			if timer_over:
				startClimbing(delta)
			if targets.size() > 0:
				if throw_nut == true:
					LookAtPlayer()
					$ThrowTimer.start(32/60.0)
					$ActionTimer.start(8/60.0)
					state = STATE.THROW
		STATE.CLIMB:
			if timer_over:
				timer_over = false
				$ActionTimer.start(16/60.0)
				$ThrowTimer.set_paused(false)
				velocity.y = 0
				animator.play("RESET")
				state = STATE.IDLE
		STATE.THROW:
			if !animator.is_playing():
				animator.play("CLIMB")
				startClimbing(delta)
			
			if timer_over:
				throwCoconut()
				timer_over = false
	
	global_position.y += (velocity.y*60*delta)
	super(delta)
	
func LookAtPlayer() -> void:
	var nearestPlayer: Player2D = GlobalFunctions.get_nearest_player_x(global_position.x)
	if nearestPlayer and nearestPlayer.global_position.x > global_position.x:
		scale.x = -1
	else: #If a player was not found, or is left.
		scale.x = 1

func startClimbing(_delta: float) -> void:
	if climb_state >= climbTimes.size():
		climb_state = 0
	timer_over = false
	$ActionTimer.start(climbTimes[climb_state]/60.0)
	$ThrowTimer.set_paused(true)
	var t: int = wrapi(climb_state,0,(climbSpeeds.size()))
	velocity.y = climbSpeeds[t]
	climb_state += 1
	animator.play("CLIMB")
	state = STATE.CLIMB

func throwCoconut() -> void:
	animator.play("THROW")
	# throw coconut
	coconut = Projectile.instantiate()
	get_parent().add_child(coconut)
	# set position with offset
	coconut.global_position = $coconuts/ThrowPoint.global_position
	coconut.scale.x = 1
	coconut.velocity.x = 0-(scale.x * 50)
	coconut.velocity.y = -1 * 100

func _on_player_check_body_entered(body: Player2D) -> void:
	targets.append(body)

func _on_player_check_body_exited(body: Player2D) -> void:
	targets.erase(body)

func _on_action_timer_timeout() -> void:
	timer_over = true
	$ActionTimer.stop()

func _on_throw_timer_timeout() -> void:
	if state == STATE.IDLE:
		throw_nut = true
