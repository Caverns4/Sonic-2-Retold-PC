extends EnemyBase

var Projectile = preload("res://Entities/Enemies/Projectiles/CoconutProjectile.tscn")
var coconut = null

enum STATE{IDLE,CLIMB,THROW}
var state = STATE.IDLE

var climbTimes = [ #Values from Sonic 2. Divide by 60.0
	32,
	24,
	16,
	40,
	32,
	16
	]

var climbSpeeds = [1,-1] #y speeds
var climb_state = 0 #Which climbing routine to do
var timer_over = false
var throw_nut = false

var targets = [] #Players in the PlayerCheckBody

@onready var animator = $AnimationPlayer

func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
	$PlayerCheck.visible = true
	super()

func _process(delta):
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
	
func LookAtPlayer():
	var nearestPlayer = GlobalFunctions.get_nearest_player_x(global_position.x)
	if nearestPlayer and nearestPlayer.global_position.x > global_position.x:
		scale.x = -1
	else: #If a player was not found, or is left.
		scale.x = 1

func startClimbing(_delta):
	if climb_state >= climbTimes.size():
		climb_state = 0
	timer_over = false
	$ActionTimer.start(climbTimes[climb_state]/60.0)
	$ThrowTimer.set_paused(true)
	var t = wrapi(climb_state,0,(climbSpeeds.size()))
	velocity.y = climbSpeeds[t]
	climb_state += 1
	animator.play("CLIMB")
	state = STATE.CLIMB

func throwCoconut():
	animator.play("THROW")
	# throw coconut
	coconut = Projectile.instantiate()
	get_parent().add_child(coconut)
	# set position with offset
	coconut.global_position = $coconuts/ThrowPoint.global_position
	coconut.scale.x = 1
	coconut.velocity.x = 0-(scale.x * 50)
	coconut.velocity.y = -1 * 100

func _on_player_check_body_entered(body):
	targets.append(body)

func _on_player_check_body_exited(body):
	targets.erase(body)

func _on_action_timer_timeout():
	timer_over = true
	$ActionTimer.stop()

func _on_throw_timer_timeout():
	if state == STATE.IDLE:
		throw_nut = true
