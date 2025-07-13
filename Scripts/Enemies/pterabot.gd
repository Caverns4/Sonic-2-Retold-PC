@tool
extends EnemyBase
# Thanks to VAdaPEGA for accuracy testing
#Todo: Get rid of dependencies from Buzzbombers

var Projectile = preload("res://Entities/Enemies/Projectiles/PterabotProjectile.tscn")

@export var bulletSound = preload("res://Audio/SFX/Gimmicks/s2br_ArrowFire.wav")
## Not a thing in Sonic 2. Do not use.
@export var flyDirection: float = 0.0 # (float,-180.0,180.0)
## Total distance travelled in pixels
@export var x_range: int = 320
## Movement Speed. 60 = 100 in Sonic 2.
@export var speed: float = 180
@onready var origin = global_position
@onready var animator = $Sprite2D/AnimationPlayer

var editorOffset: float = 1.0

var side: int = -1
var targetPosition: Vector2 = Vector2.ZERO
var cooldown_time: float = 0

func _ready():
	if !Engine.is_editor_hint():
		$VisibleOnScreenEnabler2D.visible = true
		$Sprite2D/PlayerCheck.visible = true
		var direction = Vector2(x_range*clamp(side,-1,0),0).rotated(deg_to_rad(flyDirection))
		targetPosition = origin + direction
		super()

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
		
		# move editor offset based on movement speed
		editorOffset -= (speed*delta/x_range)*2
		if editorOffset <= 0.0:
			editorOffset = 1.0
	else:
		super(delta)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		# move if not firing
		# move position toward origin point with the travel distance
		if side <= 0:
			position = position.move_toward(
				origin-Vector2(x_range,0).rotated(deg_to_rad(flyDirection)),
				speed*delta)
		else:
			position = position.move_toward(origin,speed*delta)
		# if at the destination point then turn around
		
		if position.distance_to(targetPosition) <= 1:
			$Sprite2D.scale.x = -$Sprite2D.scale.x
			#Calculate a new Target position
			side = -side
			if side <= 0:
				targetPosition = origin + Vector2(x_range*clamp(side,-1,0),0).rotated(deg_to_rad(flyDirection))
			else:
				targetPosition = origin
			# resume movement
			animator.play("FLY")
			cooldown_time = 0.0
		else:
			calc_dir()
		# count down cool down
		if cooldown_time > 0:
			cooldown_time -= delta

func calc_dir():
	# calculate direction based on side movement and rotation
	var getDir = sign(Vector2(side,0).rotated(deg_to_rad(flyDirection)).x)
	# check that it's not 0 so it doesn't become invisible
	if getDir != 0:
		$Sprite2D.scale.x = -getDir


func _draw():
	if Engine.is_editor_hint():
		var sprite = $Sprite2D/Pterabot
		var size = Vector2(sprite.texture.get_width()/sprite.hframes,sprite.texture.get_height()/sprite.vframes)
		# first Pterabot pose
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(0,0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# second Pterabot pose
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(-x_range,0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# estimated movement
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2((x_range)*(editorOffset-1.0),0).rotated(deg_to_rad(flyDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))


func _on_PlayerCheck_body_entered(_body):
	if cooldown_time <= 0:
		cooldown_time = 2.0
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
		get_parent().add_child(bullet)
		
		# set position with offset
		bullet.global_position = global_position+Vector2(0*side,16)
		bullet.scale.x = -side
		bullet.velocity = Vector2(0,60)
		
		# wait for fire aniamtion to finish
		$Timer.start(16.0/60.0)
		await $Timer.timeout
		# check that fire hasn't been deleted
		SoundDriver.play_sound(bulletSound)
		
		# last timer before returning to normal
		# account for how long the firing timer took
		$Timer.start(0.5-(16.0/60.0))
		await $Timer.timeout
		# reset sprites and resume movement
		animator.play("FLY")
		cooldown_time = 1.0 # add cooldown_time to prevent rapid fire
