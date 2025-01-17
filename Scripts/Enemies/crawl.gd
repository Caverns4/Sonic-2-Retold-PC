extends EnemyBase

const WALK_SPEED = 10
var direction = 0

var walkTimer = 8.0
var blockTimer = 0.0
var blocking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
	direction = -sign(scale.x)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !blocking:
		walkTimer -= delta
		if walkTimer < 0: # Turn around
			walkTimer = 8.0
			$crawlsprite.scale.x = direction
			direction = 0-direction
		velocity.x = direction * WALK_SPEED
	else:
		velocity.x = 0.0
	
