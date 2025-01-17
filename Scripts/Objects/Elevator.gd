@tool
extends Node2D

@export var platformSprite = preload("res://Graphics/Tiles/WorldsTiles/Platform.png")

@export var endPosition = Vector2(0,256) # End travel point for platform

@export var speed = 1.0 # How fast to move
@export var offset = 0.0 # Initial offset, this can be used to offset the movements between other platforms # (float, 0.0, 3.1415)
@export var waitTime = 4.0 #Wait time in Seconds
@export var soundFile: AudioStream

var activated = false # If the player has stood on the platform
var activeTimer = 0.0 # Timespan the ojbect has been active for. Use this instead of level timer.
var delayTimer = 0.0 #time to wait at the peak of the platform's motion.

#State machine
enum STATES{IDLE,PATHTO,COUNTDOWN,PATHFROM}
var state = STATES.IDLE

var offsetTimer = 0
var doDrop = false  # Used by child object only, here for compatability
var platformDepth = 4

func _ready():
	# Change platform shape
	$Platform/Shape3D.shape.size.x = platformSprite.get_size().x
	$Platform/Shape3D.shape.size.y = platformDepth/2.0
	$Platform/Shape3D.position.y = -(platformSprite.get_size().y/2.0)+(platformDepth/2.0)
	if !Engine.is_editor_hint():
		# Change platform sprite texture
		$Platform/Sprite2D.texture = platformSprite
		if soundFile:
			$AudioStreamPlayer.stream = soundFile
	else:
		offsetTimer = 0
	

func _process(delta):
	if Engine.is_editor_hint():
		$Platform/Shape3D.shape.size.x = platformSprite.get_size().x
		$Platform/Shape3D.shape.size.y = platformDepth/2.0
		$Platform/Shape3D.position.y = -(platformSprite.get_size().y/2.0)+(platformDepth/2.0)
		queue_redraw()
		# Offset timer for the editor to display
		offsetTimer = wrapf(offsetTimer-(delta*speed),0,PI*2)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		# Sync the position up to tween between the start and end point based on level time
		var getPos = (
			endPosition*(
				cos((activeTimer*speed)+offset)*0.5+0.5
				)
			)
		
		match state:
			STATES.IDLE:
				# Wait until activated
				if activated: 
					state = STATES.PATHTO
					activeTimer = 0.0
					if soundFile:
						$AudioStreamPlayer.play()
			STATES.PATHTO:
				#Zoom to target point endPos, inc state when target reached
				activeTimer+=(delta)
				if round(getPos) == Vector2.ZERO:
					state = STATES.COUNTDOWN
					delayTimer = waitTime
			STATES.COUNTDOWN:
			#Wait for Player to get off, await Timer waitTime
				activated = false
				delayTimer -= delta
				if delayTimer <= 0: #round(getPos) == Vector2.ZERO:
					state = STATES.PATHFROM
					if soundFile:
						$AudioStreamPlayer.play()
			STATES.PATHFROM:
				# Return home, set active to false, state = SATES.IDLE
				activeTimer+=(delta)
				if round(getPos) == endPosition:
					activated = false
					state = STATES.IDLE
		# set platform to rounded position to prevent jittering
		$Platform.position = (getPos).round()


func _draw():
	if Engine.is_editor_hint():
		# Draw the platform positions for the editor
		if speed > 0 or endPosition != Vector2.ZERO:
			draw_texture(platformSprite,-platformSprite.get_size()/2,Color(1,1,1,0.25))
			draw_texture(platformSprite,endPosition-platformSprite.get_size()/2,Color(1,0.5,0.5,0.1))
			draw_texture(platformSprite,(endPosition*(cos(offsetTimer+offset)*0.5+0.5))-platformSprite.get_size()/2,Color.WHITE)
			draw_line(Vector2.ZERO,endPosition,Color.GREEN)
