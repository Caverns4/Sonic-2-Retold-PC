@tool
extends AnimatableBody2D

@export var texture: Texture2D = preload("res://Graphics/Objects_Zone/MTZ_Platform.png")
@export_enum("Left","Right") var open_direction: int = 0

var origin = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = texture
	$Mask.shape.size.x = texture.get_width()
	
	if !Engine.is_editor_hint():
		origin = global_position
		open_direction = open_direction*2-1
		global_position.x = global_position.x + (open_direction*texture.get_width())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		if !Global.players:
			return
		
		var speed = 1024*delta
		if Global.players[0].global_position.y > global_position.y-8:
			global_position.x = move_toward(global_position.x,
			origin.x + (open_direction*texture.get_width()),
			speed)
		else:
			global_position.x = move_toward(global_position.x,origin.x,speed)
		
		$Sprite2D.global_position.x = round(global_position.x)
	else:
		$Sprite2D.texture = texture
		$Mask.shape.size.x = texture.get_width()
