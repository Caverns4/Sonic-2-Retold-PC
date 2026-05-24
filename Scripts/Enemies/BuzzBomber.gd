@tool
extends EnemyBase

var Projectile: PackedScene = preload("res://Entities/Enemies/Projectiles/BuzzBomberProjectile.tscn")
@export var bulletSound: AudioStream = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")
## Not a thing in Sonic 2. Do not use.
@export var flyDirection: float = 0.0 # (float,-180.0,180.0)
## Total distance travelled in pixels
@export var x_range: int = 256
@export var speed: float = 60

@onready var origin: Vector2 = global_position

@onready var sprite_node: Sprite2D = $Buzzer
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var flame_effect: AnimatedSprite2D = $Buzzer/BuzzerFlame
@onready var state_time: Timer = $Timers/StateTime

var editor_offset: float = 1.0
var side: int = -1
var target_pos: Vector2 = Vector2.ZERO
var bullet_ready: bool = false

func _ready() -> void:
	# clear fire if destroyed before shooting
	#var _con = connect("destroyed",Callable(self,"clear_fire"))
	if !Engine.is_editor_hint():
		var direction: Vector2 = Vector2(x_range*clamp(side,-1,0),0).rotated(deg_to_rad(flyDirection))
		target_pos = origin + direction
		super()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		
		# move editor offset based on movement speed
		editor_offset -= (speed*delta/x_range)*2
		if editor_offset <= 0.0:
			editor_offset = 1.0
	else:
		super(delta)

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		# move if not firing
		if !bullet_ready:
			# move position toward origin point with the travel distance
			if side <= 0:
				position = position.move_toward(
					origin-Vector2(x_range,0).rotated(deg_to_rad(flyDirection)),
					speed*delta)
			else:
				position = position.move_toward(origin,speed*delta)
			# if at the destination point then turn around
			
			if position.distance_to(target_pos) <= 1:
				sprite_node.scale.x = -sprite_node.scale.x
				#Calculate a new Target position
				side = -side
				if side <= 0:
					target_pos = origin + Vector2(x_range*clamp(side,-1,0),0).rotated(deg_to_rad(flyDirection))
				else:
					target_pos = origin
				# pause during turn
				animator.play("RESET")
				flame_effect.hide()
				bullet_ready = true
				state_time.start(1.0)
				await state_time.timeout
				# resume movement
				animator.play("FLY")
				flame_effect.show()
				bullet_ready = false
			else:
				calc_dir()

func calc_dir() -> void:
	# calculate direction based on side movement and rotation
	var getDir: int = sign(Vector2(side,0).rotated(deg_to_rad(flyDirection)).x)
	# check that it's not 0 so it doesn't become invisible
	if getDir != 0:
		sprite_node.scale.x = -getDir


func _draw() -> void:
	if Engine.is_editor_hint():
		var size: Vector2 = Vector2(
			sprite_node.texture.get_width()/sprite_node.hframes,
			sprite_node.texture.get_height()/sprite_node.vframes)
		# first buzzer pose
		draw_texture_rect_region(sprite_node.texture,
		Rect2(Vector2(0,0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# second buzzer pose
		draw_texture_rect_region(sprite_node.texture,
		Rect2(Vector2(-x_range,0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# estimated movement
		draw_texture_rect_region(sprite_node.texture,
		Rect2(Vector2((x_range)*(editor_offset-1.0),0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))


func _on_PlayerCheck_body_entered(_body: Player2D) -> void:
	if !bullet_ready:
		bullet_ready = true
		
		# pause
		state_time.start(0.25)
		await state_time.timeout
		# set sprites to 
		animator.play("AIM")
		flame_effect.hide()
		# start firing timer
		state_time.start(0.25)
		await state_time.timeout
		
		# fire projectile
		var bullet: Node2D = Projectile.instantiate()
		add_child(bullet)
		
		# set position with offset
		bullet.global_position = global_position+Vector2(0*side,16)
		bullet.scale.x = -side
		var alive: RefCounted = weakref(bullet)
		
		# wait for fire aniamtion to finish
		state_time.start(16.0/60.0)
		await state_time.timeout
		# check that fire hasn't been deleted
		if alive.get_ref():
			SoundDriver.play_sound(bulletSound)
			# move projectile
			bullet.velocity = Vector2(120*side,120)
			bullet.reparent(get_parent())
		
		# last timer before returning to normal
		# account for how long the firing timer took
		state_time.start(0.5-(16.0/60.0))
		await state_time.timeout
		# reset sprites and resume movement
		animator.play("FLY")
		flame_effect.show()
		bullet_ready = false
