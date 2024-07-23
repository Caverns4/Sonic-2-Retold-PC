extends EnemyBase

var Projectile = preload("res://Entities/Enemies/Projectiles/CoconutProjectile.tscn")
var coconut = null

var x_range = 96
var attack_timer = 1

enum STATE{IDLE,CLIMB,THROW}
var state = STATE.IDLE

var climbTimes = [
	0.5333333333333333,
	0.4,
	0.2666666666666667,
	0.6666666666666667,
	0.5333333333333333,
	0.2666666666666667
	] #Timer for each climb
var climbSpeeds = [1,-1] #y speeds
var climb_state = 0 #Which climbing routine to do
var timer_over = false
var throw_nut = false

var targets = [] #Players in the PlayerCheckBody

@onready var animator = $AnimationPlayer

func _process(delta):
	match state:
		STATE.IDLE:
			if timer_over:
				startClimbing()
			if targets.size() > 0:
				attack_timer = clamp(attack_timer-1,0,255) #Always
				if attack_timer == 0:
					LookAtPlayer()
					attack_timer = 32*2
					$ActionTimer.start(8/60)
					state = STATE.THROW
		STATE.CLIMB:
			if timer_over:
				timer_over = false
				$ActionTimer.start(0.25)
				$ThrowTimer.set_paused(false)
				velocity.y = 0
				animator.play("RESET")
				state = STATE.IDLE
		STATE.THROW:
			if !animator.is_playing():
				animator.play("CLIMB")
				startClimbing()
			
			if timer_over:
				throwCoconut()
				timer_over = false
	
	global_position.y += velocity.y
	super(delta)
	
func LookAtPlayer():
	var nearestplayerpos = GetClosestPlayerDistance()
	#print(nearestplayerpos)
	if nearestplayerpos:
		if nearestplayerpos > global_position.x:
			scale.x = -1
		else:
			scale.x = 1

func GetClosestPlayerDistance():
	#Return the x coordinate of the nearest player
	var j = 0 #last result
	var closest = 128 #closest distance
	var finaldist = 0 #Output number
	for i in targets.size(): #number of applicable players
		j = absf(global_position.x - targets[i].global_position.x)
		if closest > j:
			closest = j
			finaldist = round(targets[i].global_position.x)
	#print(finaldist)
	return finaldist

func startClimbing():
	if climb_state >= climbTimes.size():
		climb_state = 0
	timer_over = false
	$ActionTimer.start(climbTimes[climb_state])
	$ThrowTimer.set_paused(true)
	var t = wrapi(climb_state,0,(climbSpeeds.size()))
	velocity.y = climbSpeeds[t]/2.0
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
	throw_nut = true
