extends EnemyBase

## Blue model takes longer to throw slicers
@export_enum("Blue","Green","Red") var model: int = 0

@onready var colorMask = $Sprite2D/ColorMask

func _ready() -> void:
	match model:
		0:
			colorMask.self_modulate = Color("4444ff",1.0)
		2:
			colorMask.self_modulate = Color("ff0000",1.0)
		_:
			colorMask.visible = false
	super()

func _physics_process(delta: float) -> void:
	move_and_slide()
