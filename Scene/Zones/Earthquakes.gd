extends Node2D

@export var targetHeight = 512 #distance to move from the starting posistion

var movementTimer = 0.0

var rumbling = preload("res://Audio/SFX/Ambiance/Earthquake.wav")

#Todo

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("gm_up_P2"):
		position.y -= 1
	if Input.is_action_pressed("gm_down_P2"):
		position.y += 1
	pass
