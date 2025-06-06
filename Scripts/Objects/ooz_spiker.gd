extends CharacterBody2D

@export_enum("left","right") var direction = 0

const SPEED = 100.0

var sfx = preload("res://Audio/SFX/Gimmicks/SpikesClash.wav")

func _ready() -> void:
	if direction <= 0:
		direction = -1

func _physics_process(delta: float) -> void:
	direction = clampf(direction,-1,1)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction * SPEED
	else:
		queue_free()
	move_and_slide()
	
	if is_on_wall():
		direction = 0-direction
		if $VisibleOnScreenNotifier2D.is_on_screen():
			Global.play_sound2(sfx)
	
