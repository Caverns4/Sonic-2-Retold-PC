extends EnemyBase

## Number of projectiles this Aquis can fire before being empty.
@export var bulletCount = 3

## Movement seed cap
const SPEED = 60.0


func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
	super()

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
