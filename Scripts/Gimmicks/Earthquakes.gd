extends Node2D

@export var targetHeight = 512 #distance to move from the starting posistion

@onready var tileMap = get_child(0)

var movementTimer = 0.0
var delayTimer = 0.0
var soundTimer = 0.5

var rumbling = preload("res://Audio/SFX/Ambiance/Earthquake.wav")
var direction = -1

var bodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var got = false
	for child in get_children():
		if child is TileMapLayer and !got:
			tileMap = child
			got = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	delayTimer -= delta
	
	if bodies and delayTimer <= 0.0:
		if direction < 0:
			movementTimer += delta*16
			StepSoundEffect(delta)
		else:
			movementTimer -= delta*16
			StepSoundEffect(delta)
		
		if direction < 0 and movementTimer >= targetHeight:
			movementTimer = targetHeight
			delayTimer = 2.0
			direction = 1
		elif direction >=0 and movementTimer <= 0:
			movementTimer = 0.0
			delayTimer
			direction = -1
		
		tileMap.position.y = round(0-movementTimer)
		

func StepSoundEffect(delta):
	soundTimer -= delta
	if soundTimer <= 0:
		SoundDriver.play_sound(rumbling)
		soundTimer = 0.5
		#Also send timer to bodies to rumble camera
		for i in bodies.size():
			bodies[i].cameraShakeTime = 1.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	bodies.append(body)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	bodies.erase(body)
