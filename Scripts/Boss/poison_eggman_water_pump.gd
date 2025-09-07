extends Sprite2D

@onready var jar = $PumpPosition/Jar

var parent = null
var velocity: Vector2 = Vector2.ZERO
var fluid_level = 0
var pipe_extension = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if !parent:
		global_position += velocity
		velocity.y += 9.8*delta
	
	
	$PumpPosition/GlassPipe.position.x = $PumpPosition/Jar.position.x
	$PumpPosition/GlassPipe.size.x = pipe_extension
	
	var d0 = clamp(fluid_level,0,5)
	$PumpPosition/Jar/ColorRect.size.y = d0*4
	$PumpPosition/Jar/ColorRect.position.y = 8 - (d0*4)
