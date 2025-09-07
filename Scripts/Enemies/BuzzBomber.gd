@tool
extends EnemyBase

const SPEED = 60

var Projectile = preload("res://Entities/Enemies/Projectiles/BuzzBomberProjectile.tscn")
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")
## Not a thing in Sonic 2. Do not use.
@export var flyDirection: float = 0.0 # (float,-180.0,180.0)
## Total distance travelled in pixels
@export var x_range: int = 256
@onready var origin: Vector2 = global_position
@onready var animator = $Sprite2D/AnimationPlayer

var editor_offset: float = 1.0
var side: int = -1
var target_pos: Vector2 = Vector2.ZERO
var firing_flag: bool = false

func _ready():
	# clear fire if destroyed before shooting
	#var _con = connect("destroyed",Callable(self,"clear_fire"))
	if !Engine.is_editor_hint():
		$VisibleOnScreenEnabler2D.visible = true
		$Sprite2D/PlayerCheck.visible = true
		var direction = Vector2(x_range*clamp(side,-1,0),0).rotated(deg_to_rad(flyDirection))
		target_pos = origin + direction
		super()

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
		
		# move editor offset based on movement SPEED
		editor_offset -= (SPEED*delta/x_range)*2
		if editor_offset <= 0.0:
			editor_offset = 1.0
	else:
		super(delta)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		# move if not firing
		if !firing_flag:
			# move position toward origin point with the travel distance
			if side <= 0:
				position = position.move_toward(
					origin-Vector2(x_range,0).rotated(deg_to_rad(flyDirection)),
					SPEED*delta)
			else:
				position = position.move_toward(origin,SPEED*delta)
			# if at the destination point then turn around
			
			if position.distance_to(target_pos) <= 1:
				$Sprite2D.scale.x = -$Sprite2D.scale.x
				#Calculate a new Target position
				side = -side
				if side <= 0:
					target_pos = origin + Vector2(x_range*clamp(side,-1,0),0).rotated(deg_to_rad(flyDirection))
				else:
					target_pos = origin
				# pause during turn
				animator.play("RESET")
				firing_flag = true
				$Timer.start(1)
				await $Timer.timeout
				# resume movement
				animator.play("FLY")
				firing_flag = false
			else:
				calc_dir()

func calc_dir():
	# calculate direction based on side movement and rotation
	var getDir = sign(Vector2(side,0).rotated(deg_to_rad(flyDirection)).x)
	# check that it's not 0 so it doesn't become invisible
	if getDir != 0:
		$Sprite2D.scale.x = -getDir


func _draw():
	if Engine.is_editor_hint():
		var sprite = $Sprite2D/Buzzer
		var size = Vector2(sprite.texture.get_width()/sprite.hframes,sprite.texture.get_height()/sprite.vframes)
		# first buzzer pose
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(0,0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# second buzzer pose
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(-x_range,0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# estimated movement
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2((x_range)*(editor_offset-1.0),0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))


func _on_PlayerCheck_body_entered(_body):
	if !firing_flag:
		firing_flag = true
		
		# pause
		$Timer.start(0.25)
		await $Timer.timeout
		# set sprites to 
		animator.play("AIM")
		# start firing timer
		$Timer.start(0.25)
		await $Timer.timeout
		
		# fire projectile
		var bullet = Projectile.instantiate()
		add_child(bullet)
		
		# set position with offset
		bullet.global_position = global_position+Vector2(0*side,16)
		bullet.scale.x = -side
		var alive = weakref(bullet)
		
		# wait for fire aniamtion to finish
		$Timer.start(16.0/60.0)
		await $Timer.timeout
		# check that fire hasn't been deleted
		if alive.get_ref():
			SoundDriver.play_sound(bulletSound)
			# move projectile
			bullet.velocity = Vector2(120*side,120)
			bullet.reparent(get_parent())
		
		# last timer before returning to normal
		# account for how long the firing timer took
		$Timer.start(0.5-(16.0/60.0))
		await $Timer.timeout
		# reset sprites and resume movement
		animator.play("FLY")
		firing_flag = false
