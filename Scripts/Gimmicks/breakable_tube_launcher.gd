@tool
extends BreakableBlock

var tube_launcher = preload("res://Entities/Gimmicks/Invisible_launcher.tscn")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		$Sprite2D.texture = SpriteTexture
		queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		draw_texture(SpriteTexture,-SpriteTexture.get_size()/2,Color.WHITE)

func _on_destruction():
	var tube: Node2D = tube_launcher.instantiate()
	tube.global_position = global_position
	tube.global_rotation_degrees = global_rotation_degrees
	get_parent().add_child(tube)
