@tool
extends Node2D

@export var texture = preload("res://Graphics/Tiles/WorldsTiles/Platform.png")
## This is actually where the platform *starts*
@export var endPosition = Vector2(0,256) # End travel point for platform
## How fast this platform should move.
@export var speed: float = 1.0

## Time to wait(seconds) before this platform should return.
@export var waitTime: float = 4.0
@export var soundFile: AudioStream

var activated = false # If the player has stood on the platform
## Timespan the object has been active for.
var activeTimer = 0.0
## Time to wait at the peak of the platform's motion.
var delayTimer = 0.0

#State machine
enum STATES{IDLE,PATHTO,COUNTDOWN,PATHFROM}
var state = STATES.IDLE

var offsetTimer = 0
var platformDepth = 4

func _ready():
	# Change platform shape
	$Platform/Shape3D.shape.size.x = texture.get_size().x
	$Platform/Shape3D.shape.size.y = platformDepth/2.0
	$Platform/Shape3D.position.y = -(texture.get_size().y/2.0)+(platformDepth/2.0)
	if !Engine.is_editor_hint():
		global_position = global_position + endPosition
		endPosition.x = 0-endPosition.x
		endPosition.y = 0-endPosition.y
		# Change platform sprite texture
		$Platform/Sprite2D.texture = texture
		if soundFile:
			$AudioStreamPlayer.stream = soundFile
	else:
		offsetTimer = 0
	

func _process(delta):
	if Engine.is_editor_hint():
		$Platform/Shape3D.shape.size.x = texture.get_size().x
		$Platform/Shape3D.shape.size.y = platformDepth/2.0
		$Platform/Shape3D.position.y = -(texture.get_size().y/2.0)+(platformDepth/2.0)
		queue_redraw()
		# Offset timer for the editor to display
		offsetTimer = wrapf(offsetTimer-(delta*speed),0,PI*2)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		# Sync the position up to tween between the start and end point based on level time
		var getPos = (
			endPosition*(cos(activeTimer*speed)*0.5+0.5)
			)
		
		match state:
			STATES.IDLE:
				# Wait until activated
				if activated: 
					state = STATES.PATHTO
					activeTimer = 0.0
					if soundFile:
						$AudioStreamPlayer.play()

			STATES.COUNTDOWN:
			#Wait for Player to get off, await Timer waitTime
				activated = false
				delayTimer -= delta
				if delayTimer <= 0:
					state = STATES.PATHFROM
					if soundFile:
						$AudioStreamPlayer.play()

			STATES.PATHTO:
				activeTimer+=delta
				if round(getPos) == Vector2.ZERO:
					state = STATES.COUNTDOWN
					delayTimer = waitTime

			STATES.PATHFROM:
				activeTimer+=delta
				if round(getPos) == endPosition:
					activated = false
					state = STATES.IDLE
		# set platform to rounded position to prevent jittering
		$Platform.position = (getPos).round()


func _draw():
	if Engine.is_editor_hint():
		# Draw the platform positions for the editor
		if speed > 0 or endPosition != Vector2.ZERO:
			draw_texture(texture,-texture.get_size()/2,Color.WHITE)
			draw_texture(texture,endPosition-texture.get_size()/2,Color(1,0.5,0.5,0.5))
			draw_texture(texture,(endPosition*(cos(offsetTimer)*0.5+0.5))-texture.get_size()/2,Color.WHITE)
			draw_line(Vector2.ZERO,endPosition,Color.GREEN)
