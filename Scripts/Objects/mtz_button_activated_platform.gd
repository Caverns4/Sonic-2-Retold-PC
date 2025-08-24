@tool
extends AnimatableBody2D

## Texture2D that the object will be rendered with. Also determines collision size.
@export var texture: Texture2D = preload("res://Graphics/Objects_Zone/MTZ_Elevator.png")
## The button that triggers the motion of this platform.
@export var button: StaticBody2D = null
## The target position relative to the starting position.
@export var target_position = Vector2(128,0)
## amount of time to wait before the active state is cleared.
@export var active_time = 5.0

var origin: Vector2 = Vector2.ZERO
var active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Change platform shape
	$Mask.shape.size.x = texture.get_size().x
	$Mask.shape.size.y = texture.get_size().y
	$Sprite.texture = texture
	if !Engine.is_editor_hint():
		origin = global_position
		if button and button.has_signal("pressed"):
			button.connect("pressed",activatePlatform)

func _process(delta):
	if Engine.is_editor_hint():
		$Mask.shape.size.x = texture.get_size().x
		$Mask.shape.size.y = texture.get_size().y
		queue_redraw()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if active:
		global_position = global_position.move_toward(
			origin + target_position,
			128*delta
		)
		#global_position.x = move_toward(
		#	global_position.x,
		#	origin.x,
		#	128*delta)
	else:
		global_position = global_position.move_toward(
			origin,
			128*delta
		)
		#global_position.x = move_toward(
		#	global_position.x,
		#	origin.x+target_position.x,
		#	128*delta)


func activatePlatform():
	if active:
		return
	active = true
	await get_tree().create_timer(active_time).timeout
	active = false

func _draw():
	if Engine.is_editor_hint():
		# Draw the platform positions for the editor
		draw_texture(texture,-texture.get_size()/2,Color.WHITE)
