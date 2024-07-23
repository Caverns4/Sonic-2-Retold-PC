extends RigidBody2D

@export_enum("Front","Back") var tire = 0

func _ready():
	if tire != 0:
		$Sprite2D.frame = 2
		$Sprite2D.z_index = -2
	else:
		$Sprite2D.frame = 0
		$Sprite2D.z_index = 10

func _process(_delta):
	if Engine.is_editor_hint():
		if tire != 0:
			$Sprite2D.frame = 2
			$Sprite2D.z_index = -2
		else:
			$Sprite2D.frame = 0
			$Sprite2D.z_index = 10

func _physics_process(delta):
	pass
