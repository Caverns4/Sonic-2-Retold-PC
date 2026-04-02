extends CharacterBody2D

@export var counterWeightSprite: Texture2D = preload("res://Graphics/Enemies/Sol.png")

var animationTimer: float = 0.1
var animationFrame: int = 0
var maxFrames: int = 1

const GRAVITY = 800

var direction: int = -1
var ground: bool = false
var movement: Vector2 = Vector2.ZERO #Used to emulat Physics object

func _ready() -> void:
	direction = -1
	updateImage()

func updateImage() -> void:
	$Sprite2D.texture = counterWeightSprite
	var frameSize: int = int($Sprite2D.texture.get_height())
	maxFrames = round($Sprite2D.texture.get_width()/frameSize)
	$Sprite2D.hframes = maxFrames

func _physics_process(delta: float) -> void:
	animationTimer -= delta
	if animationTimer <= 0.0:
		animationTimer = 0.05
		animationFrame = wrapi(animationFrame+1,0,maxFrames)
		$Sprite2D.frame = animationFrame
	MoveWithGravity(delta)

func MoveWithGravity(delta: float) -> void:
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

func clearHurtbox() -> void:
	$SolArea.monitoring = false
