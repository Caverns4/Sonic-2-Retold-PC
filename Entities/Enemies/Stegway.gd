extends EnemyBase

const WALK_SPEED = 60
const DASH_SPEED = 240
const IDLE_TIME = 1.0
const GRAVITY = 600


func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
