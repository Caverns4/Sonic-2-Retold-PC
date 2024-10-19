extends EnemyBase

const WAIT_TIMER = 0.25

@export var x_range = 128 #The limit in each direction the BBat can go before not chasing farther
@onready var animator = $BBatSprite/AnimationPlayer

enum STATES{IDLE,SEEKING,WARMUP,DIVE,COOLDOWN}
var state = STATES.IDLE

var targets = [] # targets in the sensor area
var lookingForTargets = false # If the enemy is scanning for a target.
var currentTarget = null # The target picked from targets. used to remember the player.
var diveTargetPoints = []

var hoverOffset = 0.0
var origin = Vector2.ZERO #Home position. Used to check if the BBat should go no further one way or the other.
var direction = 1
var attackTimer = 0.0

func _ready():
	origin = global_position
	$VisibleOnScreenEnabler2D.visible = true
	$PlayerSensor.visible = true

func _process(delta):
	super(delta)

func _physics_process(delta):
	match state:
		STATES.IDLE:
			updateHoveringPos(delta)
			if targets and lookingForTargets:
				state = STATES.SEEKING
				animator.play("WARMUP")
				#print ("Seeking")
				$SeekTimer.start(WAIT_TIMER)
				
		STATES.SEEKING: # While awaiting $SeekTimer
			updateHoveringPos(delta)
			if targets:
				LookAtPlayer()
		STATES.WARMUP: #Warmup, and then dive at the player's x position
			if !currentTarget: #Get player from list targest and put in currentTarget
				currentTarget = GetClosestPlayer()
		STATES.DIVE: #Dive to target position, come back up to origin.y
			if attackTimer < 1.0:
				attackTimer = min(1.0,(attackTimer+(1.0*delta)))
				global_position = UpdateDiveAttackCoords(diveTargetPoints[0],diveTargetPoints[1],diveTargetPoints[2],attackTimer)
			else:
				global_position = diveTargetPoints[2]
				#clear all properties and cooldown
				attackTimer = 0.0
				currentTarget = null
				animator.play("COOLDOWN")
				state = STATES.COOLDOWN
				#print ("Cooldown")
				$SeekTimer.start(WAIT_TIMER)
		STATES.COOLDOWN:
			updateHoveringPos(delta)
	pass

func updateHoveringPos(delta):
	# change the hover offset
	global_position.y = global_position.y-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	global_position.y = global_position.y+hoverOffset

func UpdateDiveAttackCoords(p0,p1,p2,time):
	# use a quadratic bezier curve
	var q0 = p0.lerp(p1, time)
	var q1 = p1.lerp(p2, time)
	
	var r = q0.lerp(q1, time)
	return r

func LookAtPlayer():
	var nearestplayer = GetClosestPlayer()
	if nearestplayer:
		if nearestplayer.global_position.x > global_position.x:
			scale.x = -1
		else:
			scale.x = 1
		direction = scale.x

func GetClosestPlayer():
	#Return the nearest player by x_pos
	var j = 0 #last x_position result
	var closest = 160 #closest x distance
	var finaldist = 0 #Output x number
	var finalObj = null #Output object
	for i in targets.size(): #number of applicable players
		j = absf(global_position.x - targets[i].global_position.x)
		if closest > j:
			closest = j
			finaldist = round(targets[i].global_position.x)
			finalObj = targets[i]
	return finalObj

func _on_player_sensor_body_entered(body):
	targets.append(body)
	#print("Entered" + str(targets))

func _on_player_sensor_body_exited(body):
	targets.erase(body)
	#print("Exited" + str(targets))

func _on_seek_timer_timeout():
	match state:
		STATES.IDLE:
			lookingForTargets = true
		STATES.SEEKING:
			if targets:
				state = STATES.WARMUP
				animator.play("AIM")
				LookAtPlayer()
				$SeekTimer.start(WAIT_TIMER)
			else:
				BBatReturnToIdleState()
		STATES.WARMUP:
			currentTarget = Picktarget(targets)
			
			if currentTarget:
				SetupDive()
				state = STATES.DIVE
				animator.play("ATTACK")
			else:
				BBatReturnToIdleState()
		STATES.COOLDOWN:
			BBatReturnToIdleState()

func BBatReturnToIdleState():
	state = STATES.IDLE
	animator.play("RESET")
	lookingForTargets = false
	#print ("Idle")
	$SeekTimer.start(WAIT_TIMER)

func Picktarget(targets):
	# Probably bad practice but it works so ¯\_(ツ)_/¯
	var stillInRange = false
	for i in targets.size():
		if targets[i] == currentTarget:
			stillInRange = true
	
	if stillInRange and currentTarget.global_position.y > origin.y:
		return currentTarget
	else:
		return null

func SetupDive():
	LookAtPlayer()
	var diveXDist = 128*direction
	if global_position.x < (origin.x - x_range):
		diveXDist = -128
		scale.x = -1
	elif global_position.x > (origin.x + x_range):
		diveXDist = 128
		scale.x = 1
	diveTargetPoints = [global_position,
	currentTarget.global_position + Vector2(0,64),
	Vector2(global_position.x - diveXDist, origin.y)]
	
