extends CharacterBody2D

@export var counterWeightSprite = preload("res://Graphics/Enemies/Sol.png")

var animationTimer = 0.1
var animationFrame = 0
var maxFrames = 1

const GRAVITY = 800

var direction = -1
var ground = false
var movement = Vector2.ZERO #Used to emulat Physics object

func _ready():
	direction = -1
	updateImage()

func updateImage():
	$Sprite2D.texture = counterWeightSprite
	var frameSize = $Sprite2D.texture.get_height()
	maxFrames = round($Sprite2D.texture.get_width()/frameSize)
	$Sprite2D.hframes = maxFrames

func _physics_process(delta):
	animationTimer -= delta
	if animationTimer <= 0.0:
		animationTimer = 0.05
		animationFrame +=1
		if animationFrame > maxFrames:
			animationFrame = 0
		$Sprite2D.frame = animationFrame
	MoveWithGravity(delta)

func MoveWithGravity(delta):
	# Velocity movement
	set_velocity(movement)
	set_up_direction(Vector2.UP)
	move_and_slide()
	ground = is_on_floor()
	# Gravity
	if !is_on_floor():
		movement.y += GRAVITY*delta
	if is_on_floor():
		movement.y = 0

func clearHurtbox():
	$SolArea.monitoring = false
