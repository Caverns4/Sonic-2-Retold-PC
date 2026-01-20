extends CharacterBody2D

var Projectile = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")
@export var shots_remaining: int = 1

@onready var pilot:EnemyBase = $TurtloidPilot
@onready var sprite:Sprite2D = $Sprite2D

func _ready() -> void:
	velocity.x = 30.0
	$VisibleOnScreenEnabler2D.show()

func _physics_process(delta: float) -> void:
	var pos_diff = GlobalFunctions.get_orientation_to_player(global_position)
	if (abs(pos_diff.length()) <= 128 and pos_diff.x < 0):
		shots_remaining -= 1
		await get_tree().create_timer(0.1).timeout
		shoot()
	move_and_slide()

func shoot():
	if !is_instance_valid(pilot):
		return
	
	sprite.frame = 1
