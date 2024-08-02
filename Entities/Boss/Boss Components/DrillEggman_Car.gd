extends CharacterBody2D

var active = false #If this is active at all
var direction = -1 #-1 or 1
var phase = 0 #The phase of this machine
var dead = false 
var pilot = false

var currentPoint = 1 #The point for the boss to move toward while alive

@onready var tires = [
	#Back wheels
	$DrillEggmanWheel,
	$DrillEggmanWheel2,
	#Front wheels
	$DrillEggmanWheel3,
	$DrillEggmanWheel4
	]
#@onready var drill = $DrillEggmanDrill
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
	top_level = true

func _process(delta):
	if active and !dead:
		match phase:
			0:
				position.x = parent.position.x
			_:
				if !dead:
					debugControl()
	elif dead:
		velocity.y += (0.09375/GlobalFunctions.div_by_delta(delta))

func _physics_process(delta):
	if !dead:
		SetTirePositions()
	
	move_and_slide()
	UpdateDrillIfAttached()
	
	#End of step: Always tell the Boss Eggman where I am
	if parent.phase == 0:
		parent.targetPosition = global_position + Vector2(0,-11)
	elif !dead:
		parent.global_position = global_position + Vector2(0,-11)
	

func SetTirePositions():
	tires[0].position.x = position.x + (-38 * direction)
	tires[1].position.x = position.x + (-20 * direction)
	tires[2].position.x = position.x + (15 * direction)
	tires[3].position.x = position.x + (36 * direction)
	for i in tires.size():
		tires[i].updateAnim(velocity.x)
	#Update the Vehicle itself
	var posbuff = (tires[0].global_position.y + tires[1].global_position.y)/2
	posbuff += (tires[2].global_position.y + tires[3].global_position.y)/2
	posbuff = round(posbuff/2) - 16
	global_position.y = posbuff

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
	#drill.global_position.x = global_position.x + (-54 * direction)
	#drill.global_position.y = global_position.y + 8
	#if direction > 0:
	#	drill.get_child(0).flip_h = false #Sprite2D
	#else:
	#	drill.get_child(0).flip_h = true #Sprite2D
	pass

func Die():
	dead = true
	velocity = Vector2.ZERO
	tires[0].velocity.x = 100.0
	tires[1].velocity.x = -100.0
	tires[2].velocity.x = 100.0
	tires[3].velocity.x = -100.0
	tires[0].free = true
	tires[1].free = true
	tires[2].free = true
	tires[3].free = true



func _on_area_2d_area_entered(area): #Await Eggman to enter
	if phase == 0 and active and !dead:
		emit_signal("carTouched")
		velocity = Vector2.ZERO
		await get_tree().create_timer(1.0)
		phase = 1


func _on_boss_boundry_setter_boss_start():
	if !active:
		active = true
