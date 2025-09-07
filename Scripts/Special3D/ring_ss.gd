extends Node3D

const MAX_LIFETIME = 256.0/60.0
var scattered = false
var lifetime = MAX_LIFETIME
var velocity = Vector2.ZERO
var player

var Particle = preload("res://Entitites3D/AnimatedParticle3D.tscn")

@onready var floor_ray = $RayCast3D
@onready var shadow_sprite = $CharacterShadow

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player):
		player.get_ring()
		var part = Particle.instantiate()
		get_parent().add_child(part)
		part.global_position = global_position
		part.play("RingSparkle")
		queue_free()


func _physics_process(delta: float) -> void:
	if floor_ray.is_colliding():
		shadow_sprite.global_position = floor_ray.get_collision_point()
		var scale_factor: float = 1.0 - (
		global_position.distance_to(floor_ray.get_collision_point())/10)
		scale_factor = clampf(scale_factor,0.0,1.0)
		shadow_sprite.scale = Vector3(scale_factor,1.0,scale_factor)
	else:
		shadow_sprite.scale = Vector3.ZERO

func _on_hitbox_body_entered(body: Node3D) -> void:
	if (player != body):
		if (!scattered) or (scattered and lifetime < (3.3)):
			player = body


func _on_hitbox_body_exited(body: Node3D) -> void:
	if (player == body):
		player = null
