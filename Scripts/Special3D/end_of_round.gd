extends Area3D

func _ready() -> void:
	$MeshInstance3D.queue_free()

func _on_body_entered(body: Node3D) -> void:
	Global.hud.SetupNextRound(false)
	queue_free()
