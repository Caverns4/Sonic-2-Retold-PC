extends CharacterBody2D


@export var drillSound = preload("res://Audio/SFX/Boss/Motor.wav")

const DRIVE_SPEED = 120 #2 ppf, 60 FPS = 120

var active = false #If this is active at all
var direction = -1 #-1 or 1
var phase = 0 #The phase of this machine
var dead = false
var pilot = false
var readyToLaunch = false #If true, shoot the drill when the player is in front

var currentPoint = 1 #The point for the boss to move toward while alive

@onready var tires = [
	#Back wheels
	$DrillEggmanWheel,
	$DrillEggmanWheel2,
	#Front wheels
	$DrillEggmanWheel3,
	$DrillEggmanWheel4
	]
@onready var drill = $DrillEggmanDrill
var parent = null #The parent node, should be Helicopter Eggman

signal carTouched()

func _ready():
	tires[0].top_level = true
	tires[0].global_position.y = global_position.y
	tires[1].top_level = true
	tires[1].global_position.y = global_position.y
	tires[2].top_level = true
	tires[2].global_position.y = global_position.y
	tires[3].top_level = true
	tires[3].global_position.y = global_position.y
	parent = get_tree().get_root().find_child("HelicopterEggman",true,false)
	if !parent:
		queue_free()
	top_level = true

func _process(delta):
	if active and !dead:
		match phase:
			0:
				position.x = parent.position.x
			1:
				if pilot:
					# Pick a target (Really sloppily done)
					if currentPoint == 0 and global_position.x < parent.getPose[0].x:
						currentPoint = 1
					if currentPoint != 0 and global_position.x > parent.getPose[1].x:
						currentPoint = 0
					# Move to target
					if currentPoint == 0:
						direction = -1
					else:
						direction = 1
					velocity.x = direction*DRIVE_SPEED
					parent.direction = direction
			_:
				if pilot:
					debugControl()
	elif dead:
		velocity.y += (0.09375/GlobalFunctions.div_by_delta(delta))

func _physics_process(delta):
	if !dead:
		SetTirePositions()
	
	move_and_slide()
	UpdateDrillIfAttached()
	
	#End of step: Always tell the Boss Eggman where I am
	if parent and is_instance_valid(parent) and parent.phase == 0:
		parent.targetPosition = global_position + Vector2(0,-11)
	elif pilot:
		parent.global_position = global_position + Vector2(0,-11)
	

func SetTirePositions():
	var tireOffsets = [-38,-20,12,36]
	
	for i in tires.size():
		tires[i].position.x = position.x - (tireOffsets[i] * direction)
		tires[i].updateAnim(velocity.x)
	#Update the Vehicle itself
	var posbuff = (tires[0].global_position.y + tires[1].global_position.y)/2
	posbuff += (tires[2].global_position.y + tires[3].global_position.y)/2
	posbuff = round(posbuff/2) - 16
	global_position.y = posbuff
	
	if direction > 0:
		$Sprite2D.flip_h = true
		$DrillLaunchBox/CollisionShape2D.position.x = 150
	else:
		$Sprite2D.flip_h = false
		$DrillLaunchBox/CollisionShape2D.position.x = -150
	

func debugControl():
	if phase != 0 and pilot:
		if Input.is_action_just_pressed("gm_left_P2"):
			direction = -1
			$Sprite2D.flip_h = false
		if Input.is_action_just_pressed("gm_right_P2"):
			direction = 1
			$Sprite2D.flip_h = true
		velocity.x = direction*100
		parent.direction = direction

func UpdateDrillIfAttached():
	if drill:
		drill.global_position.x = global_position.x - (-54 * direction)
		drill.global_position.y = global_position.y + 8
		drill.scale.x = -1.0 * direction

func Die():
	dead = true
	pilot = false
	velocity = Vector2.ZERO
	tires[0].velocity.x = 200.0
	tires[1].velocity.x = 300.0
	tires[2].velocity.x = -200.0
	tires[3].velocity.x = -300.0
	tires[0].free = true
	tires[1].free = true
	tires[2].free = true
	tires[3].free = true
	if drill:
		drill.monitoring = false
		drill.free = true
		drill.position = drill.global_position
		drill.direction = direction
		drill.top_level = true
		drill = null
		readyToLaunch = false

func playMotor():
	Global.play_sound(drillSound)
	if drill: drill.monitoring = true

func _on_area_2d_area_entered(area): #Await Eggman to enter
	if phase == 0 and active and !dead:
		emit_signal("carTouched")
		velocity = Vector2.ZERO
		currentPoint = 0
		await get_tree().create_timer(3.0)
		phase = 1


func _on_boss_boundry_setter_boss_start():
	if !active:
		active = true

func _on_drill_launch_box_body_entered(body):
	if readyToLaunch and drill:
		drill.free = true
		drill.position = drill.global_position
		drill.direction = direction
		drill.top_level = true
		drill = null
		readyToLaunch = false
