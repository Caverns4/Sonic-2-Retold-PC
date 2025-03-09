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

@onready var sprite = $Sprite2D/BFishSprite2

var side = -1
var editorOffset = 1
enum STATES{IDLE,ATTACK,HOME}
var state = STATES.IDLE
var startPosition: Vector2
var stateTimer = 0.0

var bubbleTimer = 0.0
var Bubble = preload("res://Entities/Misc/Bubbles.tscn")
var players = []

func _ready():
	if !Engine.is_editor_hint():
		$VisibleOnScreenEnabler2D.visible = true
		startPosition = global_position
	super()

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
		position = position.move_toward(startPosition+Vector2(travelDistance*side,0).rotated(deg_to_rad(swimDirection)),25*delta)
		match state:
			STATES.IDLE:
				BFish_IdleState()
			STATES.ATTACK:
				if players:
					BFish_Attack(delta,players[0].global_position)
				else:
					stateTimer -= delta
					if stateTimer <= 0.0:
						if startPosition.x < global_position.x:
							sprite.scale.x = 1
						else:
							sprite.scale.x = -1
						state = STATES.HOME
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
	if position.distance_to(startPosition+Vector2(travelDistance*side,0).rotated(deg_to_rad(swimDirection))) <= 1:
		side = -side
		sprite.scale.x = side
		# resume movement
		sprite.play("default")
	else:
		calc_dir()
	BFish_ForceUnderwater()

func BFish_Attack(delta, playerCords):
	position = position.move_toward(playerCords.rotated(deg_to_rad(swimDirection)),100*delta)
	BFish_ForceUnderwater()

func BFish_ReturnHome(delta):
	position.x = move_toward(position.x,startPosition.x,60*delta)
	position.y = move_toward(position.y,startPosition.y,60*delta)
	
	if global_position == startPosition:
		state = STATES.IDLE
	calc_dir()

func BFish_ForceUnderwater():
	if Global.waterLevel != null and (global_position.y < Global.waterLevel):
		global_position.y = Global.waterLevel


func calc_dir():
	# calculate direction based on side movement and rotation
	var getDir = sign(Vector2(side,0).rotated(deg_to_rad(swimDirection)).x)
	# check that it's not 0 so it doesn't become invisible
	if getDir != 0:
		sprite.scale.x = -getDir


func _draw():
	if Engine.is_editor_hint():
		var test = $Sprite2D/Sample
		
		var size = Vector2(test.texture.get_width()/test.hframes,test.texture.get_height()/test.vframes)
		# first bomber pose
		draw_texture_rect_region(test.texture,
		Rect2(Vector2(travelDistance,0).rotated(deg_to_rad(swimDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))
		
		# second bomber pose
		draw_texture_rect_region(test.texture,
		Rect2(Vector2(-travelDistance,0).rotated(deg_to_rad(swimDirection))-size/2,
		size),Rect2(Vector2(0,0),
		size),Color(1,1,1,0.5))


func _on_player_check_body_entered(body: Node2D) -> void:
	state = STATES.ATTACK
	sprite.play("attack")
	players.append(body)
	stateTimer = 2.0

func _on_player_check_body_exited(body: Node2D) -> void:
	players.erase(body)
