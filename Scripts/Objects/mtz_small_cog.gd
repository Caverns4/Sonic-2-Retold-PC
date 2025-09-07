extends Sprite2D

@export var animation_speed = 0.1

var saved_position: int = 0.0
var frame_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pos = global_position
	top_level = true
	global_position = pos
	
	saved_position = round(get_parent().global_position.x)


func _physics_process(delta: float) -> void:
	var test_position = round(get_parent().global_position.x)
	if test_position != saved_position:
		frame_timer += delta
		if frame_timer > animation_speed:
			frame_timer = 0.0
			if test_position > saved_position:
				frame = wrapi(frame+1,0,vframes)
			else:
				frame = wrapi(frame-1,0,vframes)
		saved_position = test_position
