@tool
extends Area2D

@onready var screenSize: Vector2 = get_viewport().get_visible_rect().size

@export var setLeft: bool = true
@export var leftBoundry: int = 0
@export var setTop: bool = true
@export var topBoundry: int = 0

@export var setRight: bool = true
@export var rightBoundry: int = 320
@export var setBottom: bool = true
@export var bottomBoundry: int = 224

@export var screen_ranges: Vector2 = Vector2(1,1)

## The speed at which that camera should update.
@export var scroll_time: float = 0.0

func _ready() -> void:
	if (!Engine.is_editor_hint()):
		if Global.two_player_mode:
			queue_free()
		else:
			$CollisionShape2D.scale = screen_ranges

func _on_BoundrySetter_body_entered(body: Player2D) -> void:
	# set boundry settings
	if (!Engine.is_editor_hint()):
		# Check body has a camera variable
		if body.camera and !Global.stage_cleared:
			# Check if set boundry is true, if it is then set the camera's boundries
			if setLeft:
				body.limitLeft = max(leftBoundry,Global.hardBorderLeft)
				body.camera_limits_target[0] = leftBoundry
			if setTop:
				body.limitTop = max(topBoundry,Global.hardBorderTop)
				body.camera_limits_target[1] = topBoundry
			if setRight:
				body.limitRight = min(rightBoundry,Global.hardBorderRight)
				body.camera_limits_target[2] = rightBoundry
			if setBottom:
				body.limitBottom = min(bottomBoundry,Global.hardBorderBottom)
				body.camera_limits_target[3] = bottomBoundry
			body.camera_shift_time = scroll_time


func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()):
		queue_redraw()
		# remember to change this for your game if the screen size gets changed, this is just for debugging
		screenSize = Vector2(320,224)
		rightBoundry = max(leftBoundry+screenSize.x,rightBoundry)
		bottomBoundry = max(topBoundry+screenSize.y,bottomBoundry)
		$CollisionShape2D.scale = screen_ranges

func _draw() -> void:
	if (Engine.is_editor_hint()):
		# Left boundry
		draw_line((Vector2(leftBoundry,topBoundry)-global_position)*scale,(Vector2(leftBoundry,bottomBoundry)-global_position)*scale,Color.WHITE)
		# Top boundry
		draw_line((Vector2(leftBoundry,topBoundry)-global_position)*scale,(Vector2(rightBoundry,topBoundry)-global_position)*scale,Color.WHITE)
		# Right boundry
		draw_line((Vector2(rightBoundry,topBoundry)-global_position)*scale,(Vector2(rightBoundry,bottomBoundry)-global_position)*scale,Color.WHITE)
		# Bottom boundry
		draw_line((Vector2(leftBoundry,bottomBoundry)-global_position)*scale,(Vector2(rightBoundry,bottomBoundry)-global_position)*scale,Color.WHITE)
