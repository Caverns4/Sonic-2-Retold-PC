@tool
extends Node2D

@export var platformSprite: Texture2D = preload("res://Graphics/Obstacles/Blocks/CPZ Block.png")
@export_enum("Up","Down") var direction: int = 0

# The taget position of each child stair block, in order, by phase, clockwise
#State machine
enum STATES{IDLE,PATH,END}
var state: STATES = STATES.IDLE

# Each block MUST be 32x32 pixels, witth vertical sprites
var spriteFrame: int = 0
var maxFrames: int = 1

# Each target Y pos relative to center, in order of child
var targetPositions: Array[Vector2] = [Vector2(0,-32),Vector2(0,-64),Vector2(0,-96),Vector2(0,-128)]

var activated: bool = false # If the player has stood on the platform
var activeTimer: float = 0.0 # Timespan the ojbect has been active for. Use this instead of level timer.


func _ready() -> void:
	maxFrames = platformSprite.get_height()/32
	if direction > 0:
		targetPositions = [Vector2(0,32),Vector2(0,64),Vector2(0,96),Vector2(0,128)]
	activeTimer = 3.15
	
	if !Engine.is_editor_hint():
		# Change platform sprite texture
		for i in get_child_count():
			var temp: Node2D = get_child(i)
			temp.visible = true
			for j in temp.get_child_count():
				if temp.get_child(j) is Sprite2D:
					temp.get_child(j).texture = platformSprite
				elif temp.get_child(j) is CollisionShape2D:
					temp.get_child(j).shape.size.x = 32
					temp.get_child(j).shape.size.y = 32
	else:
		for i in get_child_count():
			var temp: Node2D = get_child(i)
			for j in temp.get_child_count():
				if temp.get_child(j) is Sprite2D:
					temp.get_child(j).texture = platformSprite

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		var getPos: Array[Vector2] = [Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO]
		# Sync the position up to tween between the start and end point based on level time
		for i in targetPositions.size():
			getPos[i] = (
				targetPositions[i]*(
					cos(activeTimer)*0.5+0.5
					)
				)
				
		match state:
			STATES.IDLE:
				# Wait until activated
				if activated: 
					state = STATES.PATH
			STATES.PATH:
				#Zoom to target point endPos, inc state when target reached
				activeTimer+=(delta)
				if round(getPos[3].y) == targetPositions[3].y:
					state = STATES.END
		
		for i in targetPositions.size():
			get_child(i).position.y = round(getPos[i].y)
		setvframeOfChildren(delta)


func setvframeOfChildren(_delta: float) -> void:
	spriteFrame = wrapi(round(Global.globalTimer*6.0),0,maxFrames)
	for i in get_child_count():
		var temp: Node2D = get_child(i)
		for j in temp.get_child_count():
			if temp.get_child(j) is Sprite2D:
				temp.get_child(j).set_region_rect(Rect2(0,(spriteFrame*32),32,32))
