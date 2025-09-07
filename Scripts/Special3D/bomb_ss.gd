extends Node3D


var player

var Particle = preload("res://Entitites3D/AnimatedParticle3D.tscn")
var sfx = preload("res://Audio/SFX/Gimmicks/s2br_Collapse.wav")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player):
		SoundDriver.play_sound(sfx)
		player.hit_player(global_position,10)
		var part = Particle.instantiate()
		get_parent().add_child(part)
		part.global_position = global_position
		part.play("default")
		queue_free()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if (player != body):
		player = body


func _on_hitbox_body_exited(body: Node3D) -> void:
	if (player == body):
		player = null
