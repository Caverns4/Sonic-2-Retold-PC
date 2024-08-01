extends CharacterBody2D

@export var range = 512 # Range in pixels from the center to drive
var ignition = false # If the vehicle is started
var direction = 1.0 #-1 or 1

@onready var tires = [
	#Back wheels
	$DrillEggmanWheel,
	$DrillEggmanWheel2,
	#Front wheels
	$DrillEggmanWheel3,
	$DrillEggmanWheel4
	]
@onready var drill = $DrillEggmanDrill


func _ready():
	tires[0].top_level = true
	tires[0].global_position.y = global_position.y
	tires[1].top_level = true
	tires[1].global_position.y = global_position.y
	tires[2].top_level = true
	tires[2].global_position.y = global_position.y
	tires[3].top_level = true
	tires[3].global_position.y = global_position.y

func _process(delta):
	velocity.x = 0

func _physics_process(delta):
	if Input.is_action_just_pressed("gm_left_P2"):
		direction = 1.0
		$Sprite2D.flip_h = false
	if Input.is_action_just_pressed("gm_right_P2"):
		direction = -1.0
		$Sprite2D.flip_h = true
	if Input.is_action_pressed("gm_left_P2"):
		velocity.x = 0-direction*50
	if Input.is_action_pressed("gm_right_P2"):
		velocity.x = 0-direction*50
	SetTirePositions()

	var posbuff = (tires[0].global_position.y + tires[1].global_position.y)/2
	posbuff += (tires[2].global_position.y + tires[3].global_position.y)/2
	posbuff = round(posbuff/2) - 16
	global_position.y = posbuff
	
	move_and_slide()
	UpdateDrillIfAttached()

func SetTirePositions():
	tires[0].position.x = position.x + (-38 * direction)
	tires[1].position.x = position.x + (-20 * direction)
	tires[2].position.x = position.x + (15 * direction)
	tires[3].position.x = position.x + (36 * direction)
	
	for i in tires.size():
		tires[i].updateAnim(velocity.x)

func UpdateDrillIfAttached():
	drill.global_position.x = global_position.x + (-54 * direction)
	drill.global_position.y = global_position.y + 8
	if direction > 0:
		drill.get_child(0).flip_h = false #Sprite2D
	else:
		drill.get_child(0).flip_h = true #Sprite2D
