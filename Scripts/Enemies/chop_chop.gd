@tool
extends EnemyBase

@export var travelDistance = 128
@export var swimDirection = 0.0 # (float,-180.0,180.0)
@onready var origin = global_position

@onready var sprite = $ChopchopSprite

var side = -1
enum STATES{IDLE,ATTACK,HOME}
var state = STATES.IDLE
var stateTimer = 0.0

var bubbleTimer = 0.0
var Bubble = preload("res://Entities/Misc/Bubbles.tscn")
var TargetPosition = Vector2.ZERO

func _ready():
	if !Engine.is_editor_hint():
		$VisibleOnScreenEnabler2D.visible = true
		origin = global_position

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		super(delta)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		position = position.move_toward(origin+Vector2(travelDistance*side,0).rotated(deg_to_rad(swimDirection)),15*delta)
		match state:
			STATES.IDLE:
				BFish_IdleState()
			STATES.ATTACK:
				stateTimer -= delta
				BFish_Attack(delta,TargetPosition)
				if stateTimer <= 0:
					state = STATES.HOME
					sprite.play("default")
			STATES.HOME:
				BFish_ReturnHome(delta)
		
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
	elif global_position.y < Global.waterLevel:
		global_position.y += 1
	if position.distance_to(origin+Vector2(travelDistance*min(side,0),0).rotated(deg_to_rad(swimDirection))) <= 1:
		sprite.scale.x = -sprite.scale.x
		side = -side
		# resume movement
		sprite.play("default")
	else:
		calc_dir()

func BFish_Attack(delta, playerCords):
	global_position = global_position.move_toward(playerCords.rotated(deg_to_rad(swimDirection)),120*delta)

func BFish_ReturnHome(delta):
	position.x = move_toward(position.x,origin.x,60*delta)
	position.y = move_toward(position.y,origin.y,60*delta)
	
	var getDir: int = -1
	if origin.x > global_position.x:
		getDir = 1
	sprite.scale.x = -getDir
	swimDirection = getDir
	
	if global_position == origin:
		state = STATES.IDLE
		TargetPosition = Vector2.ZERO

func calc_dir():
	# calculate direction based on side movement and rotation
	var getDir = sign(Vector2(side,0).rotated(deg_to_rad(swimDirection)).x)
	# check that it's not 0 so it doesn't become invisible
	if getDir != 0:
		sprite.scale.x = -getDir


func _draw():
	if Engine.is_editor_hint():
		var test = $Sample
		
		var size = Vector2(test.texture.get_width()/test.hframes,test.texture.get_height()/test.vframes)
		
		# first Chopchop pose
		draw_texture_rect_region(test.texture,
		Rect2(Vector2(-travelDistance,0).rotated(deg_to_rad(swimDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))


func _on_player_check_body_entered(body: Node2D) -> void:
	if TargetPosition == Vector2.ZERO and  state == STATES.IDLE:
		state = STATES.ATTACK
		sprite.play("attack")
		stateTimer = 2.0
		TargetPosition = global_position + (Vector2(body.global_position - global_position).normalized()*160)
		
		#Vector2(120,0).rotated(get_angle_to(body.global_position))


func _on_player_check_body_exited(body: Node2D) -> void:
	pass
