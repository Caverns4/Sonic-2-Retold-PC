@tool
extends EnemyBase

#Behavior:
#Swim idle left/right at var distance
#When Player enters eyesight body,agro
#When Agro, swim towards player at 3*60*delta
#if player if above water, jump at them.
#If sight of either player is lost for 3 seconds, lose agro, swim home
#Return to idel state once home, unless player seen again.

@export var travelDistance = 160
@export var swimDirection = 0.0 # (float,-180.0,180.0)
@onready var origin = global_position

@onready var animator = $Sprite2D/AnimationPlayer
@onready var sprite = $Sprite2D/BFishSprite

var side = -1
var editorOffset = 1
enum STATES{IDLE,ATTACK,GOHOME}
var state = STATES.IDLE
var startPosition: Vector2

var bubbleTimer = 0.0
var Bubble = preload("res://Entities/Misc/Bubbles.tscn")

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
		# move editor offset based on movement speed
		if editorOffset > -1:
			editorOffset -= (25*delta/travelDistance)*2
		else:
			editorOffset = 1
	else:
		super(delta)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		position = position.move_toward(origin+Vector2(travelDistance*side,0).rotated(deg_to_rad(swimDirection)),25*delta)
		match state:
			STATES.IDLE:
				BFish_IdleState()
			_:
				BFish_IdleState()
		
		if Global.waterLevel != null and global_position.y > Global.waterLevel:
			bubbleTimer += 1*delta
			if bubbleTimer > 2.0:
				var bubble = Bubble.instantiate()
				# pick either 0 or 1 for the bubble type
				bubble.bubbleType = 0 #int(round(randf()))
				add_sibling(bubble)
				bubble.global_position = global_position
				bubbleTimer = 0.0



func BFish_IdleState():
	if Global.waterLevel == null:
		queue_free()
	elif Global.waterLevel != null and global_position.y < Global.waterLevel:
		global_position.y += 8
	if position.distance_to(origin+Vector2(travelDistance*side,0).rotated(deg_to_rad(swimDirection))) <= 1:
		sprite.scale.x = -sprite.scale.x
		side = -side
		# resume movement
		animator.play("RESET")
	else:
		calc_dir()

func BFish_Attack(delta, playerCords):
	position = position.move_toward(playerCords.rotated(deg_to_rad(swimDirection)),100*delta)

func BFish_ReturnHome(delta):
	position = position.move_toward(origin.rotated(deg_to_rad(swimDirection)),25*delta)
	calc_dir()

func calc_dir():
	# calculate direction based on side movement and rotation
	var getDir = sign(Vector2(side,0).rotated(deg_to_rad(swimDirection)).x)
	# check that it's not 0 so it doesn't become invisible
	if getDir != 0:
		sprite.scale.x = -getDir


func _draw():
	if Engine.is_editor_hint():
		var size = Vector2(sprite.texture.get_width()/sprite.hframes,sprite.texture.get_height()/sprite.vframes)
		# first bomber pose
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(travelDistance,0).rotated(deg_to_rad(swimDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# second bomber pose
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(-travelDistance,0).rotated(deg_to_rad(swimDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# estimated movement
		draw_texture_rect_region(sprite.texture,
		Rect2(Vector2(travelDistance*clamp(editorOffset,-1,1),0).rotated(deg_to_rad(swimDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))


