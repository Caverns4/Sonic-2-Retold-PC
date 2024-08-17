@tool
extends Node2D

@export var platformSprite = preload("res://Graphics/Obstacles/Blocks/CPZ Block.png")
@export var speed = 0.5 # How fast to move
@export_enum("Clockwise","Counter-Clockwise") var direction = 0

# The taget position of each child stair block, in order, by phase, clockwise
var phase = 0
#Todo: Custom dimension support, allow hiding inner-2 children

# Each block MUST be 32x32 pixels, witth vertical sprites
var spriteFrame = 0
var maxFrames = 1

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
	maxFrames = platformSprite.get_height()/32
	if !Engine.is_editor_hint():
		# Change platform sprite texture
		for i in get_child_count():
			var temp = get_child(i)
			for j in temp.get_child_count():
				if temp.get_child(j) is Sprite2D:
					temp.get_child(j).texture = platformSprite
	else:
		for i in get_child_count():
			var temp = get_child(i)
			for j in temp.get_child_count():
				if temp.get_child(j) is Sprite2D:
					temp.get_child(j).texture = platformSprite
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
		setvframeOfChildren(delta)
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

func setvframeOfChildren(delta):
	spriteFrame = wrapi(round(Global.globalTimer*6.0),0,maxFrames)
	for i in get_child_count():
		var temp = get_child(i)
		for j in temp.get_child_count():
			if temp.get_child(j) is Sprite2D:
				temp.get_child(j).set_region_rect(Rect2(0,(spriteFrame*32),32,32))
