extends Area3D

func _ready() -> void:
	$MeshInstance3D.queue_free()

func _on_body_entered(body: Node3D) -> void:
	body.global_rotation.y = global_rotation.y
	body.global_rotation.x = global_rotation.x
