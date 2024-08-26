@tool
extends Node2D

@export var platformSprite = preload("res://Graphics/Tiles/WorldsTiles/Platform.png")
@export var endPosition = Vector2(256,0) # End travel point for platform
@export var speed = 1.0 # How fast to move
@export var offset = 0.0 # Initial offset, this can be used to offset the movements between other platforms # (float, 0.0, 3.1415)

@export var dropSlightly = true # Drop slightly when a player stands on top
@export var fallTimer = 0.0 # does the platform fall? 0 sets it to not fall
@export var fullySolid = false # if true, all collision layers are active fore this object.

var offsetTimer = 0
var dropDistance = 0
var fallSpeed = 0
var fallActive = false
var doDrop = false
var platformDepth = 4

func _ready():
	# Change platform shape
	if fullySolid:
		$Platform/Shape3D.shape.size.x = platformSprite.get_size().x
		$Platform/Shape3D.shape.size.y = platformSprite.get_size().y
		$Platform/Shape3D.position.y = (platformDepth*2.0)
		$Platform/Shape3D.one_way_collision = false
		$Platform.set_collision_layer_value(2,true)
		$Platform.set_collision_layer_value(3,true)
		$Platform.set_collision_layer_value(4,true)
	else:
		$Platform/Shape3D.shape.size.x = platformSprite.get_size().x
		$Platform/Shape3D.shape.size.y = platformDepth/2.0
		$Platform/Shape3D.position.y = -(platformSprite.get_size().y/2.0)+(platformDepth/2.0)

	if !Engine.is_editor_hint():
		# Change platform sprite texture
		$Platform/Sprite2D.texture = platformSprite
	else:
		offsetTimer = 0
	

func _process(delta):
	if Engine.is_editor_hint():
		if fullySolid:
			$Platform/Shape3D.shape.size.x = platformSprite.get_size().x
			$Platform/Shape3D.shape.size.y = platformSprite.get_size().y
			$Platform/Shape3D.position.y = (platformDepth*2.0)
		else:
			$Platform/Shape3D.shape.size.x = platformSprite.get_size().x
			$Platform/Shape3D.shape.size.y = platformDepth/2.0
			$Platform/Shape3D.position.y = -(platformSprite.get_size().y/2.0)+(platformDepth/2.0)
		queue_redraw()
		# Offset timer for the editor to display
		offsetTimer = wrapf(offsetTimer+(delta*speed),0,PI*2)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		# Sync the position up to tween between the start and end point based on level time
		var getPos = (endPosition*(cos((Global.globalTimer*speed)+offset)*0.5+0.5))
		# set platform to rounded position to prevent jittering
		if fallSpeed == 0:
			$Platform.position = (getPos+Vector2(0,dropDistance)).round()
		else:
			$Platform.translate(Vector2(0,fallSpeed))
		
		# drop
		
		if doDrop:
			# if a player collision was detected then activate fall if fall timer greater then 0
			if fallTimer > 0:
				fallActive = true
			# drop is drop slightly variable is active
			if dropSlightly:
				dropDistance += delta*16
		else:
			# return to normal
			dropDistance -= delta*16
		
		# clamp drop
		dropDistance = clamp(dropDistance,0,4)
		
		# falling
		if fallActive:
			fallTimer -= delta
			# if timer runs out start falling
			if fallTimer <= 0:
				fallSpeed += delta*20
			# clear if fall speed above a certain range to clear up resources
			if fallSpeed > 32:
				queue_free()
		
		# set doDrop to false for next loop, see platform child for collision
		doDrop = false


func _draw():
	if Engine.is_editor_hint():
		# Draw the platform positions for the editor
		if speed > 0 or endPosition != Vector2.ZERO:
			draw_texture(platformSprite,-platformSprite.get_size()/2,Color(1,1,1,0.5))
			draw_texture(platformSprite,endPosition-platformSprite.get_size()/2,Color(1,1,1,0.5))
			draw_texture(platformSprite,(endPosition*(cos(offsetTimer+offset)*0.5+0.5))-platformSprite.get_size()/2,Color.WHITE)
			draw_line(Vector2.ZERO,endPosition,Color.GREEN)
