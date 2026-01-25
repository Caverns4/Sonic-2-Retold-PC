extends CharacterBody2D

var Projectile = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")
@export var shots_remaining: int = 1

@onready var pilot:EnemyBase = $TurtloidPilot
@onready var sprite:Sprite2D = $Sprite2D

func _ready() -> void:
	velocity.x = 30.0
	$VisibleOnScreenEnabler2D.show()

func _physics_process(_delta: float) -> void:
	var pos_diff = GlobalFunctions.get_orientation_to_player(global_position)
	if (abs(pos_diff.length()) <= 128 and pos_diff.x < 0 and shots_remaining):
		shots_remaining -= 1
		shoot()
	move_and_slide()

func shoot():
	if !is_instance_valid(pilot):
		return
	await get_tree().create_timer(0.1).timeout
	sprite.frame = 1
	# fire projectile
	var bullet = Projectile.instantiate()
	add_child(bullet)
	SoundDriver.play_sound(bulletSound)
	# set position with offset
	bullet.global_position = global_position+Vector2(-32,16)
	bullet.velocity = Vector2(-60,0)
	await get_tree().create_timer(0.5).timeout
	sprite.frame = 0
