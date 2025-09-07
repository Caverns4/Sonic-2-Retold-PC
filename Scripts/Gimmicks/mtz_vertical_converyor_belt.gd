@tool
extends Node2D

## Texture for the platform to inherit at runtime. The size  of the collision box is also inherited from here.
@export var texture: Texture2D = preload("res://Graphics/Gimmicks/MTZ_CupPlatform.png")
## Number of Child Platforms on the conveyor Belt.
@export var platform_count: int = 8
## Total Movement Speed
@export var speed = 1.0
## Total Height of the conveyer belt.
@export var height: int = 384

## horizonal size of the chain
const WIDTH: float = 32

var platforms: Array[AnimatableBody2D] =[]
@onready var platform = $MTZ_CupPlatform # Grab the platform's node.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Engine.is_editor_hint():
		platforms.append(platform)
		var nextChild = null
		for i in platform_count-1:
			nextChild = platform.duplicate()
			add_child(nextChild)
			platforms.append(nextChild)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func  _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		# Calcutlate direction
		var direction = Vector2.DOWN
		var xOffset = 0.0
		for i in platforms.size():
			direction = Vector2.DOWN.rotated((deg_to_rad(fmod(xOffset + Global.globalTimer * 15 * speed,360))))
			xOffset += (360.0/platform_count)
			var testPos = direction*(height/2)
			testPos.x = clampf(testPos.x,0-WIDTH,WIDTH)
			platforms[i].position = (testPos).round()


func _draw() -> void:
	if Engine.is_editor_hint():
		# Draw the platform positions for the editor
		draw_texture(texture,-texture.get_size()/2 - Vector2(0,height/2),Color.WHITE)
		draw_texture(texture,-texture.get_size()/2 + Vector2(0,height/2),Color.WHITE)
