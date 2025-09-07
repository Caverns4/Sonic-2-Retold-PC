extends "res://Scripts/Objects/Hazard.gd"

var projectile = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")
var bullet = null

var landed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CollisionShape2D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !landed:
		global_position.y += delta*60
		$AnimatedSprite2D.global_position.y = round(global_position.y)
		if $RayCast2D.is_colliding():
			landed = true
			$AnimatedSprite2D.play("Bubble")
			$CollisionShape2D.disabled = false
			$CollisionShape2D.shape.size.x = 24
			$CollisionShape2D.shape.size.y = 24


func _on_animated_sprite_2d_animation_finished() -> void:
	spawnProjectile(Vector2(120,-120))
	spawnProjectile(Vector2(-120,-120))
	spawnProjectile(Vector2(60,-60))
	spawnProjectile(Vector2(-60,-60))
	queue_free()

func spawnProjectile(movement = Vector2.ZERO):
	bullet = projectile.instantiate()
	bullet.gravity = true
	bullet.global_position = global_position
	bullet.velocity = movement
	get_parent().add_child(bullet)
