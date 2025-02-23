extends Node3D

const MAX_LIFETIME = 256.0/60.0
var scattered = false
var lifetime = MAX_LIFETIME
var velocity = Vector2.ZERO
var player

var Particle = preload("res://Entitites3D/AnimatedParticle3D.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player):
		player.get_ring()
		var part = Particle.instantiate()
		get_parent().add_child(part)
		part.global_position = global_position
		part.scale = Vector3(5,5,5)
		part.play("RingSparkle")
		queue_free()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if (player != body):
		if (!scattered) or (scattered and lifetime < (3.3)):
			player = body


func _on_hitbox_body_exited(body: Node3D) -> void:
	if (player == body):
		player = null
