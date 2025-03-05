extends EnemyBase

#Unlike other badniks, this one doesn't have any logic to look for players.
#It will just shoot a projectile when the head reach its furthest extent.

var Projectile = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")
var bullet = null
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")

var shootFlag = false # If true, shoot bullet.

func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
