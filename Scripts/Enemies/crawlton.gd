extends Node2D

@export var neckSegments = 8

@onready var head = $CrawltonHead

var children = [] #List of nodes for each child and the head
var childPositions = [Vector2.ZERO] #position of each child and the head

enum STATES{SCAN,EXTEND,WAIT,RETRACT}
var state: int = 0
var state_timer: float = 0.0
var taret_position: Vector2 = Vector2.ZERO
var extend_length = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Mostly copypasted from Rexon
	var currentPos = Vector2.ZERO
	children.append($Neck1)
	childPositions[0] = currentPos
	
	for i in max(0,neckSegments-1):
		var node = $Neck1.duplicate(8)
		add_child(node)
		children.append(node)
		childPositions.insert(childPositions.size(),currentPos)
		node.global_position = (global_position + currentPos)
		currentPos -= Vector2(0,8)
	
	children.append(head)
	childPositions.insert(childPositions.size(),currentPos)
	head.global_position = (global_position + currentPos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !head:
		children.erase(head)
		for node in children:
			if node:
				node.queue_free()
				children.erase(node)
		for node in get_children():
			if node is not Sprite2D:
				node.scale.x = 1
				node.reparent(get_parent())
		queue_free()
	else:
		match state:
			STATES.SCAN:
				state_timer -= delta
				if state_timer <= 0.0:
					var look_at = GlobalFunctions.get_orientation_to_player(global_position)
					if abs(look_at.length()) <= 128:
						state = STATES.EXTEND
						state_timer = 0.0
						taret_position = look_at
						if head.scale.x > 0:
							head.scale.x = 1
						else:
							head.scale.x = -1
						#print(taret_position)
			STATES.EXTEND:
				if extend_length < taret_position.length()/8:
					extend_length += delta*32
				else:
					state = STATES.WAIT
					state_timer = 1.0
			STATES.WAIT:
				state_timer -= delta
				if state_timer <= 0.0:
					state = STATES.RETRACT
			STATES.RETRACT:
				if extend_length > 0.0:
					extend_length -= delta*32
				else:
					extend_length = 0
					state = STATES.SCAN
					state_timer = 1.0
	
		var yOffset = 0.0
		var direction = taret_position.normalized()
		for i in children.size():
			children[i].position = (direction * yOffset).round()
			yOffset += min(extend_length,16)
