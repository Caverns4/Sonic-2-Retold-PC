extends ColorRect

## TEST for a new water overlay implimentations that will play nice with mulitplayer.


@export var water_level = 512
@export var camera: Camera2D

func _ready() -> void:
	Global.waterLevel = water_level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var width: float = get_viewport_rect().size.x * 2
	
	size.x = width
	global_position.x = clampf(
		((camera.position.x+camera.offset.x)-(width/2)),
		camera.limit_left,
		camera.limit_right-(width/2))
	global_position.y = max(water_level,camera.position.y-112)
