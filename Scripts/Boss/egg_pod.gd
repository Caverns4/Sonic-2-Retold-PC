extends CharacterBody2D

## Scene instantiated when the Tornado is on a timer.
var explosion = preload("res://Entities/Misc/GenericParticle.tscn")
@export var pop_sfx = preload("res://Audio/SFX/Boss/s2br_SmallExplosion.wav") 

@onready var animation = $AnimationPlayer
@onready var ballon_hit_box = $CollisionShape2D
@onready var hitbox = $Area2D

## If this Eggpod is still connected to the mech.
var connected: bool = true
var vulnerable: bool = false

var angle: float = 0.0

func _physics_process(delta: float) -> void:
	if connected:
		return
	handle_jumping(delta)
	move_and_slide()
	

func update_direction():
	$Sprite2D.flip_h = velocity.x > 0.0

func handle_jumping(delta):
	if is_on_floor():
		velocity.y = -60
		var player = GlobalFunctions.get_nearest_player_x(global_position.x)
		var diff = player.global_position.x - global_position.x 
		velocity.x = sign(diff) * 90
		update_direction()
	else:
		velocity.y += 30.0*delta
		if is_on_wall():
			velocity.x = 0-velocity.x
			update_direction()


func break_away():
	var saved_position = global_position
	connected = false
	reparent(get_parent().get_parent().get_parent())
	global_position = saved_position
	animation.play("free")
	ballon_hit_box.disabled = false

## Only one animation, so that's probably all that's needed.
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	vulnerable = true
	$Area2D.global_scale = Vector2(2,2)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player2D:
		var player:Player2D = body
		if !vulnerable or (!player.attacking and !player.supTime):
			player.hit_player(global_position)
		elif player.attacking or player.supTime:
			queue_free()
			Global.add_score(global_position,1,Global.players.find(player))
			
			var skipBounce = (player.animator.current_animation == "drop")
			if !player.ground and !(skipBounce):
				if player.movement.y > 0:
					# Bounce high upward
					player.movement.y = -player.movement.y
				else:
					# Bounce slightly down
					player.movement.y += 120
					
			var this: AnimatedSprite2D = explosion.instantiate()
			this.play("Pop")
			this.global_position = global_position - Vector2(0,00)
			this.z_index = 30
			this.top_level = true
			SoundDriver.play_sound2(pop_sfx)
			get_parent().get_parent().add_child(this)
