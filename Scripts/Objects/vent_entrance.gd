extends CharacterBody2D

@export var lock_left_camera: int = 0

var explosion_scene: PackedScene = preload("res://Entities/Misc/GenericParticle.tscn")
var sfx: AudioStream = preload("res://Audio/SFX/Objects/s2br_Destroy.wav")

# physics collision check, see physics object
func physics_collision(body: Player2D, hitVector: Vector2) -> void:
	if body.attacking and hitVector.y > 0:
		var explod:AnimatedSprite2D = explosion_scene.instantiate()
		explod.play("Explosion")
		explod.global_position = global_position
		get_parent().add_child(explod)
		SoundDriver.play_sound2(sfx)
		if lock_left_camera > 0:
			for i in Global.players:
				i.limitLeft = lock_left_camera
				i.camera_limits_target[0] = i.limitLeft
		
		queue_free()
	#print("Echo")
