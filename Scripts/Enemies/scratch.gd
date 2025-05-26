extends EnemyBase

var Projectile = preload("res://Entities/Enemies/Projectiles/ScratchProjectile.tscn")
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")

var state: int = 0
var state_timer: float = 0.0
var origin: = Vector2.ZERO
var direction = -1
var active_flag: bool = false
var shots_queued: int = 0

@onready var sprite = $CluckerSprite

func _ready() -> void:
	super()
	direction = -sign(scale.x)
	global_position.y += 32
	origin = global_position
	$DamageArea.monitoring = false

func _physics_process(delta: float) -> void:
	var diff = GlobalFunctions.get_orientation_to_player(global_position)
	
	if abs(diff.length()) < 128 and state == 0:
		state = 1
		$DamageArea.monitoring = true
		shots_queued = 3
		state_timer = 0.5
	elif abs(diff.length()) > 128 and !active_flag:
		state = 0
		$DamageArea.monitoring = false
	
	match state:
		0:
			if !active_flag:
				var target_pos = origin.y
				global_position.y = move_toward(global_position.y,target_pos,64*delta)
		1: #Active
			state_timer -= delta
			var target_pos = origin.y-32
			global_position.y = move_toward(global_position.y,target_pos,64*delta)

			if global_position.y == target_pos and !active_flag and state_timer <= 0:
				#Prioritize shooting
				if shots_queued > 0:
					active_flag = true
					sprite.play("Shoot")
					shootBullet()
					return
				
				var dir_test = sign(diff.x)
				if dir_test != direction and dir_test != 0:
					active_flag = true
					sprite.play("Turn")
					state_timer = 1.0
					shots_queued = 3
				

func shootBullet():
	# Shoot stabdard bullet
	Global.play_sound(bulletSound)
	var bullet = Projectile.instantiate()
	get_parent().add_child(bullet)
	# set position with offset
	bullet.global_position = global_position + Vector2(16*direction,8)
	bullet.scale.x = 1
	bullet.velocity.x = (direction * 180)

func _on_clucker_sprite_animation_finished() -> void:
	active_flag = false
	if sprite.animation == "Turn":
		direction = 0-direction
		scale.x = 0-scale.x
		sprite.play("default")
	if sprite.animation == "Shoot":
		shots_queued -= 1
		if shots_queued == 0:
			$ReloadTimer.start(1.0)
	sprite.play("default")


func _on_reload_timer_timeout() -> void:
	shots_queued = 3
