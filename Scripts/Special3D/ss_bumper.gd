extends Node3D

@onready var sprite = $AnimatedSprite3D
@onready var sfx = $AudioStreamPlayer

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.inertia and body.inertia > 0:
		sprite.play("bounce")
		sfx.play()
		body.inertia = -16.0
