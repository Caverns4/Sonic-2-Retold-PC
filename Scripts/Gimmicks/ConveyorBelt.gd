@tool
extends StaticBody2D

@export var speed: float = 60
var frame: int = 0
@export var length: float = 1

func _ready() -> void:
	if Engine.is_editor_hint():
		# sprite related animations
		$MiddlePiece.region_rect.size.x = length*32
		$LeftCog.position.x = -length*16
		$RightCog.position.x = length*16
		$CollisionShape2D.scale.x = length+1
	else:
		$MiddlePiece.queue_free()
		$LeftCog.queue_free()
		$RightCog.queue_free()
	# constant linear velocity is a constant speed set in godot's physics
	constant_linear_velocity.x = speed

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$MiddlePiece.region_rect.size.x = length*32
		$LeftCog.position.x = -length*16
		$RightCog.position.x = length*16
		$CollisionShape2D.scale.x = length+1
		
		frame = wrapi(round(frame+(delta*speed/2)),0,3)
		
		$MiddlePiece.frame = (floor(frame)*3)+2
		$LeftCog.frame = (floor(frame)*3)
		$RightCog.frame = (floor(frame)*3)+1
	else:
		$CollisionShape2D.scale.x = length+1
		frame = wrapi(round(frame+(delta*speed/2)),0,3)
