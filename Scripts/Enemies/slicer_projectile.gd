extends EnemyProjectileBase

var move_dir: int = 1
var slicer_tracking_time: float = 4.0
var target: Player2D = null
var parent = null

const acceleration = 360

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	slicer_tracking_time -= delta
	$ClawSprites.rotate(deg_to_rad((20*(move_dir))))
	var diff = target.global_position - global_position
	
	if slicer_tracking_time > 0 and parent != null:
		velocity.x += acceleration*sign(diff.x)*delta
		velocity.y += acceleration*sign(diff.y)*delta
		
		velocity.x = clampf(velocity.x,-120,120)
		velocity.y = clampf(velocity.y,-120,120)
	else:
		velocity.y += 9.8*60*delta
		velocity.x = move_toward(velocity.x,0,acceleration*delta)
		if global_position.y > 2048:
			queue_free()
	
	move_and_slide()
