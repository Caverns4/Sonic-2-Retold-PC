extends AnimatableBody2D

@export var rest_time: float = 1.0
@export var spring_power: float = 600.0
@export var spring_sfx = preload("res://Audio/SFX/Gimmicks/s2br_Spring.wav")

var Projectile = preload("res://Entities/Hazards/SteamPuff.tscn")

var players: Array[Player2D] = []

var origin: Vector2 = Vector2.ZERO
var target_pos: int = 0
var timer: float = rest_time
var direction: int = 1

func _ready() -> void:
	origin = global_position + Vector2(0,16)
	target_pos = global_position.y

func _process(delta: float) -> void:
	timer -= delta
	if timer <=0.0 and !direction:
		var pos_sign  = sign(0-sign(global_position.y-origin.y)*2-1)
		direction = pos_sign
		target_pos = direction*16+origin.y
	
	if direction < 0:
		for player in players:
			player.movement.y = -60+(0-abs(spring_power))
			player.set_state(player.STATES.AIR)
			player.air_control = true
			player.angle = 0
			player.animator.play("spring")
			player.animator.queue("curAnimwalk")
			SoundDriver.play_sound(spring_sfx)
	players.clear()

func _physics_process(delta: float) -> void:
	if direction:
		global_position.y = move_toward(global_position.y,target_pos,256*delta)
		if global_position.y == target_pos:
			if direction < 0:
				var y_pos = global_position.y - 12
				
				var bullet = Projectile.instantiate()
				get_parent().add_child(bullet)
				bullet.global_position.x = global_position.x-32
				bullet.global_position.y = y_pos
				bullet.scale.x = -1
				
				bullet = Projectile.instantiate()
				get_parent().add_child(bullet)
				bullet.global_position.x = global_position.x+32
				bullet.global_position.y = y_pos
			
			direction = 0
			timer = rest_time


func physics_collision(body, hitVector):
	if hitVector.y > 0.0:
		players.append(body)
