extends EnemyBase

var Projectile = preload("res://Entities/Enemies/Projectiles/ScratchProjectile.tscn")
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")

var state: int = 0
var stateTimer: float = 0.0

func _physics_process(delta: float) -> void:
	pass
