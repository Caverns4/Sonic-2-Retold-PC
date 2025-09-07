extends StaticBody2D


var delay = 8.0/60.0
var activated = false
var velocity = Vector2.ZERO #Used to make the "fake" physics.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:	
	if activated:
		if $Area2D:
			$Area2D.queue_free()
		delay -= delta
		if delay <= 0.0:
			velocity.y += 9.8*delta
			global_position += velocity
		if $RayCast2D.is_colliding():
			activated = false
			velocity = Vector2.ZERO
		while $RayCast2D.is_colliding():
			global_position.y = round(global_position.y-1)
			$RayCast2D.force_raycast_update()


func _on_area_2d_body_entered(body: Node2D) -> void:
	activated = true
