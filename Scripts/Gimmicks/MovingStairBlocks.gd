@tool
extends Node2D

@export var platformSprite = preload("res://Graphics/Obstacles/Blocks/CPZ Block.png")
@export var speed = 0.5 # How fast to move
@export_enum("Closwise","Counter-Clockwise") var direction = 0

# The taget position of each child stair block, in order, by phase, clockwise
var phase = 0

# Each target pos relative to center, in order of child, by phase
var targetPositions = [
	[Vector2(-48,-48),Vector2(-16,-16),Vector2( 16, 16),Vector2( 48, 48)],
	# + x
	[Vector2( 48,-48),Vector2( 16,-16),Vector2(-16, 16),Vector2(-48, 48)],
	# + y
	[Vector2( 48, 48),Vector2( 16, 16),Vector2(-16,-16),Vector2(-48,-48)],
	# - x
	[Vector2(-48, 48),Vector2(-16, 16),Vector2( 16,-16),Vector2( 48,-48)],
]
var stateTimer = 0.0

var offsetTimer = 0 #To be used for editor preview if I feel like figuring it out

func _ready():
	if !Engine.is_editor_hint():
		# Change platform sprite texture
		$Platform/Sprite2D.texture = platformSprite
	else:
		$Platform/Sprite2D.texture = platformSprite
		offsetTimer = 0
	

func _process(delta):
	if Engine.is_editor_hint():
		$Platform/Shape3D.shape.size.x = platformSprite.get_size().x
		$Platform/Shape3D.shape.size.y = platformSprite.get_size().y
		queue_redraw()
		# Offset timer for the editor to display
		offsetTimer = wrapf(offsetTimer+(delta*speed),0,PI*2)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		stateTimer = stateTimer+(delta*speed)
		positionChildren(delta)
		if stateTimer >= 1.0:
			if direction > 0:
				phase -= 1
			else:
				phase += 1
			stateTimer = 0
			phase = wrapi(phase,0,targetPositions.size())
	#if !Engine.is_editor_hint():
	#	# Sync the position up to tween between the start and end point based on level time
	#	var getPos = (endPosition*(cos((Global.globalTimer*speed))*0.5+0.5))
	#	# set platform to rounded position to prevent jittering
	#	$Platform.position = (getPos).round()

func positionChildren(delta):
	var getPos = Vector2.ZERO
	var curArray = targetPositions[phase]
	var lastArray = targetPositions[wrapi(phase-1,0,targetPositions.size())]
	
	if direction > 0:
		lastArray = targetPositions[wrapi(phase+1,0,targetPositions.size())]
	
	for i in get_child_count():
		# Get the facotr if the difference, therefore the total distance
		var operand = get_child(i)
		getPos = lastArray[i] + ((curArray[i]-lastArray[i]) * stateTimer)
		operand.position = round(getPos)
