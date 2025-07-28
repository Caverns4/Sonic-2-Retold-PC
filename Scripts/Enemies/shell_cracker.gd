extends EnemyBase

@export var chain_length = 8
@export var move_speed = 30
@export var walk_time = 1.0
@export var cooldown_time = 2.0
@onready var _claw:Node2D = $ClawAttack
@onready var _animation:AnimationPlayer = $AnimationPlayer

var children = [] #List of nodes for each child and the head
var childPositions = [Vector2.ZERO] #position of each child and the head
var extend_length = 0.0
var taret_position = 0.0

enum  STATE{WALK,WAIT,JAB}
var state: int = 0
var state_time: float = 1.0
var move_dir: int = -1


func _ready() -> void:
	#Mostly copypasted from Rexon
	var currentPos = $ChainLink.position
	children.append($ChainLink)
	childPositions[0] = currentPos
	
	for i in max(0,chain_length-1):
		var node = $ChainLink.duplicate(DUPLICATE_SCRIPTS)
		add_child(node)
		children.append(node)
		childPositions.insert(childPositions.size(),currentPos)
		node.global_position = (global_position + currentPos)
	
	children.append(_claw)
	childPositions.insert(childPositions.size(),currentPos)
	_claw.global_position = (global_position + currentPos)
	
	velocity.x = 30*move_dir
	defaultMovement = false
	super()

func _physics_process(delta: float) -> void:
	match state:
		STATE.WALK:
			state_time -= delta
			
			var look_at = GlobalFunctions.get_orientation_to_player(global_position)
			if abs(look_at.length()) <= 128 and look_at.x < 0:
				state = STATE.JAB
				velocity.x = 0
				taret_position = chain_length * 2
			
			if state_time <= 0.0:
				state = STATE.WAIT
				state_time = 1.0
				cooldown_time = 2.0
				velocity.x = 0
		STATE.WAIT:
			state_time -= delta
			cooldown_time -= delta
			if state_time <= 0.0:
				state = STATE.WALK
				state_time = walk_time
				move_dir = 0-move_dir
				velocity.x = move_speed*move_dir
		STATE.JAB:
			if extend_length < taret_position:
				extend_length += delta*32
			else:
				taret_position = 0
				extend_length = max(extend_length-delta*32,0.0)
			
			var xOffset = 0.0
			for i in children.size():
				children[i].position.x = round(-14-(xOffset))
				xOffset += min(extend_length,8)
			
			if extend_length == 0:
				state = STATE.WALK
				velocity.x = move_speed*move_dir

	if !is_on_floor():
		velocity.y += 9.8*delta
	move_and_slide()
	if is_on_wall() and state == 0:
		move_dir = 0-move_dir
		velocity.x = move_speed*move_dir
	
	if velocity.x != 0:
		_animation.play("Walk")
	else:
		_animation.play("RESET")

func destroy():
	for i in children:
		var node: Node2D = i
		node.reparent(get_parent(),true)
		node.velocity = Vector2(-30,-60)
		node.parent = null
		for child in node.get_children():
			if child is Area2D:
				child.monitoring = false
	super()
