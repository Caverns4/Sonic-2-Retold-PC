extends EnemyProjectileBase

var explosionSFX = preload("res://Audio/SFX/Boss/s2br_BossExplosion.wav")
var particle = preload("res://Entities/Misc/GenericParticle.tscn")

@export var gravity = false

func _process(delta: float) -> void:
	if gravity:
		velocity.y += 400*delta
	super(delta)
	if $RayCast2D.is_colliding():
		Global.play_sound2(explosionSFX)
		var debris = particle.instantiate()
		debris.global_position = global_position
		debris.play("BombExplode")
		get_parent().add_child(debris)
		queue_free()
