extends Node2D

@export var range = 512 # Range in pixels from the center to drive
var ignition = false # If the vehicle is started

@onready var tires = [
	$DrillEggmanWheel,
	$DrillEggmanWheel2,
	$DrillEggmanWheel3,
	$DrillEggmanWheel4
	]
	
@onready var drill = $DrillEggmanDrill

func _input(event):
	if Input.is_action_pressed("gm_left"):
		scale.x = 1
		position.x -=1
	if Input.is_action_pressed("gm_right"):
		scale.x = -1
		position.x += 1

func _process(delta):
	tires[0].position.x = position.x - (15 * scale.x)
	tires[1].position.x = position.x - (-32 * scale.x)
	tires[2].position.x = position.x - (36 * scale.x)
	tires[3].position.x = position.x - (-9 * scale.x)

func _physics_process(delta):
	var posbuff = (tires[0].position.y + tires[1].position.y)/2
	posbuff += (tires[2].position.y + tires[3].position.y)/2
	posbuff = round(posbuff/2) - 16
	position.y = posbuff
	pass
