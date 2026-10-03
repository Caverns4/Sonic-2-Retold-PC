@tool
extends Node2D

@export var platformSprite: Texture2D = preload("res://Graphics/Obstacles/Blocks/CPZ Block.png")
@export_enum("two","four") var childCount: int = 1
@export var speed: float = 1.0 # How fast to move
@export_enum("Clockwise","Counter-Clockwise") var direction: int = 0

# The taget position of each child stair block, in order, by current_point, clockwise
var current_point: int = 0
# Each block MUST be 32x32 pixels, witth vertical sprites
var spriteFrame: int = 0
var maxFrames: int = 1

# Each target pos relative to center, in order of child, by current_point
var target_points: Array = [
	[Vector2(-48,-48),Vector2( 48, 48),Vector2(-16,-16),Vector2( 16, 16)],
	# + x
	[Vector2( 48,-48),Vector2(-48, 48),Vector2( 16,-16),Vector2(-16, 16)],
	# + y
	[Vector2( 48, 48),Vector2(-48,-48),Vector2( 16, 16),Vector2(-16,-16)],
	# - x
	[Vector2(-48, 48),Vector2( 48,-48),Vector2(-16, 16),Vector2( 16,-16)],
]

var stateTimer: float = 0.0

var offsetTimer: float = 0 #To be used for editor preview if I feel like figuring it out

func _ready() -> void:
	@warning_ignore('integer_division')
	maxFrames = platformSprite.get_height()/platformSprite.get_width()
	if !Engine.is_editor_hint():
		if childCount == 0:
			get_child(1).queue_free()
			get_child(2).queue_free()
		# Change platform sprite texture
		for i in get_child_count():
			var temp: Node2D = get_child(i)
			temp.visible = true
			for j in temp.get_child_count():
				if temp.get_child(j) is Sprite2D:
					temp.get_child(j).texture = platformSprite
				elif temp.get_child(j) is CollisionShape2D:
					temp.get_child(j).shape.size.x = platformSprite.get_size().x
					temp.get_child(j).shape.size.y = platformSprite.get_size().x
	else:
		for i in get_child_count():
			var temp: Node2D = get_child(i)
			for j in temp.get_child_count():
				if temp.get_child(j) is Sprite2D:
					temp.get_child(j).texture = platformSprite
		offsetTimer = 0
	

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		# Offset timer for the editor to display
		offsetTimer = wrapf(offsetTimer+(delta*speed),0,PI*2)

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		stateTimer = stateTimer+(delta*(speed/2.0))
		positionChildren(delta)
		if stateTimer >= 1.0:
			if direction > 0:
				current_point -= 1
			else:
				current_point += 1
			stateTimer = 0
			current_point = wrapi(current_point,0,target_points.size())
		setvframeOfChildren(delta)

func positionChildren(_delta: float) -> void:
	var getPos: Vector2 = Vector2.ZERO
	var curArray: Array = target_points[current_point]
	var lastArray: Array = target_points[wrapi(current_point-1,0,target_points.size())]
	
	if direction > 0:
		lastArray = target_points[wrapi(current_point+1,0,target_points.size())]
	
	for i in get_child_count():
		# Get the facotr if the difference, therefore the total distance
		var operand: Node2D = get_child(i)
		getPos = lastArray[i] + ((curArray[i]-lastArray[i]) * stateTimer)
		operand.position = round(getPos)

func setvframeOfChildren(_delta: float) -> void:
	spriteFrame = wrapi(round(Global.globalTimer*6.0),0,maxFrames)
	for i in get_child_count():
		var temp: Node2D = get_child(i)
		for j in temp.get_child_count():
			if temp.get_child(j) is Sprite2D:
				temp.get_child(j).set_region_rect(Rect2(0,(spriteFrame*platformSprite.get_width()),platformSprite.get_width(),platformSprite.get_width()))

func _draw() -> void:
	if Engine.is_editor_hint():
		# Draw the platform positions for the editor
		var drawVec: Array = target_points[0]
		if direction > 0:
			drawVec = target_points[1]
		var drawLoop: int = ((childCount + 1) * 2) #Number of times to draw
		
		for i: int in drawLoop:
			draw_texture_rect(
				platformSprite,
				Rect2(drawVec[i].x - (platformSprite.get_size().x/2)
				,drawVec[i].y - (platformSprite.get_size().x/2)
				,platformSprite.get_size().x
				,platformSprite.get_size().x),
				true,
				Color(1,1,1,1.0)
			)
