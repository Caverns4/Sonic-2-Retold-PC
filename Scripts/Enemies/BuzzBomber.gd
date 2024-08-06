@tool
extends EnemyBase
# Thanks to VAdaPEGA for accuracy testing
#Todo: Get rid of dependencies from Buzzbombers

var Projectile = preload("res://Entities/Enemies/Projectiles/BuzzBomberProjectile.tscn")

@export var flyDirection = 0.0 # (float,-180.0,180.0)
@export var travelDistance = 256
@export var speed = 100
@onready var origin = global_position
@onready var animator = $Sprite2D/AnimationPlayer

var side = -1

var editorOffset = 1

var isFiring = false
var fireTime = 0
var coolDown = 0

var fire = null

func _ready():
	# clear fire if destroyed before shooting
	var _con = connect("destroyed",Callable(self,"clear_fire"))

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
		
		# move editor offset based on movement speed
		if editorOffset > -1:
			editorOffset -= (speed*delta/travelDistance)*2
		else:
			editorOffset = 1
	else:
		super(delta)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		# move if not firing
		if !isFiring:
			# move position toward origin point with the travel distance
			position = position.move_toward(origin+Vector2(travelDistance*side,0).rotated(deg_to_rad(flyDirection)),speed*delta)
			# if at the destination point then turn around
			if position.distance_to(origin+Vector2(travelDistance*side,0).rotated(deg_to_rad(flyDirection))) <= 1:
				$Sprite2D.scale.x = -$Sprite2D.scale.x
				side = -side
				# pause during turn
				animator.play("RESET")
				isFiring = true
				$Timer.start(1)
				await $Timer.timeout
				# resume movement
				animator.play("FLY")
				isFiring = false
			else:
				calc_dir()
			# count down cool down
			if coolDown > 0:
				coolDown -= delta

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
		# first bomber pose
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(travelDistance,0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# second bomber pose
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(-travelDistance,0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# estimated movement
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(travelDistance*clamp(editorOffset,-1,1),0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))


func _on_PlayerCheck_body_entered(_body):
	if !isFiring and coolDown <= 0:
		isFiring = true
		
		# pause
		$Timer.start(0.25)
		await $Timer.timeout
		
		# set sprites to 
		animator.play("AIM")
		fireTime = 1
		
		# start firing timer
		$Timer.start(0.25)
		await $Timer.timeout
		
		# fire projectile
		fire = Projectile.instantiate()
		get_parent().add_child(fire)
		
		# set position with offset
		fire.global_position = global_position+Vector2(0*side,16)
		fire.scale.x = -side
		
		# create a weakref to verify projectile hasn't been deleted later
		var wrFire = weakref(fire)
		# wait for fire aniamtion to finish
		$Timer.start(16.0/60.0)
		await $Timer.timeout
		# check that fire hasn't been deleted
		if wrFire.get_ref():
			# move projectile
			fire.velocity = Vector2(120*side,120)
		
		# remove fire variable
		fire = null
		# last timer before returning to normal
		# account for how long the firing timer took
		$Timer.start(0.5-(16.0/60.0))
		await $Timer.timeout
		# reset sprites and resume movement
		animator.play("FLY")
		isFiring = false
		coolDown = 1 # add cooldown to prevent rapid fire

func clear_fire():
	if fire != null:
		fire.queue_free()
