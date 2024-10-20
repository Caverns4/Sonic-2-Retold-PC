extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func physics_collision(body, hitVector):
	#if get_parent().get("activated") != null:
	if body.get("character") != null:
		if body.character == Global.CHARACTERS.KNUCKLES or (
			body.character == Global.CHARACTERS.SONIC and body.isSuper):
			body.movement.x = 200 * body.direction
			body.velocity = body.movement
			queue_free()
		if hitVector.y > 0.0:
			body.movement.y = 200
			body.velocity.y = 200
			body.ground = false
			body.animator.current_animation = "roll"
			queue_free()
