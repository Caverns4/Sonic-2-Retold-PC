@tool
extends Node2D

@export var endDistance = int(256) # End travel point for platform

var activated = false #If the player has stood on the platform
var motionScale = 0.0
var direction = 1
var speed = Vector2.ZERO

@onready var platformSprite = preload("res://Graphics/Objects_Zone/HTZ_ZipPlatform.png")
var soundEffect = preload("res://Audio/SFX/Gimmicks/HTZ_Liftclick.wav")

#State machine
enum STATES{IDLE,PATH,COLLAPSE,DEAD}
var state = STATES.IDLE
var offsetTimer = 0
var standees = []

func _ready():
	if Engine.is_editor_hint():
		offsetTimer = 0
	else:
		direction = scale.x

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
		# Offset timer for the editor to display
		offsetTimer = wrapf(offsetTimer-(delta*1.0),0,PI*2)
	

func _physics_process(delta):
	if !Engine.is_editor_hint():
		
		match state:
			STATES.IDLE:
				if activated == true and standees.has(Global.players[0]):
					motionScale = 0.0
					state = STATES.PATH
			STATES.PATH:
				motionScale += (96.0*delta)
				CountDownSound(delta)
				var getPos = Vector2(motionScale,motionScale/2.0)
				if motionScale > abs(endDistance):
					motionScale = abs(endDistance)
				$Platform.position = (getPos+Vector2(0,88)).ceil()
				if motionScale ==  abs(endDistance):
					state = STATES.COLLAPSE
					motionScale = 0.0
					var savedPos = $Platform/VineSprite.global_position
					$Platform/VineSprite.frame = 1
					$Platform/VineSprite.top_level = true
					$Platform/VineSprite.global_position = savedPos
					$Platform/VineSprite.scale = scale
					$Platform/VineSprite.reparent(self)
			STATES.COLLAPSE:
				motionScale -= delta
				if motionScale < 0.0:
					$Platform.position += speed
					speed.y += delta*9.8
				if motionScale < -256.0:
					$Platform.queue_free()
					state = STATES.DEAD

func CountDownSound(delta):
	offsetTimer += delta
	if offsetTimer >= 0.25:
		Global.play_sound(soundEffect)
		offsetTimer = 0.0

func _draw():
	if Engine.is_editor_hint():
		# Draw the platform positions for the editor
		if endDistance != 0:
			draw_texture(platformSprite,
			Vector2((endDistance-32),(endDistance/2)+80),
			Color(1,1,1,0.5))
			draw_line(Vector2(0,80),Vector2(endDistance,abs(endDistance/2)+80),Color.GREEN)
