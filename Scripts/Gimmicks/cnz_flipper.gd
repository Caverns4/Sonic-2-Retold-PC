extends StaticBody2D

#Todo
@export_enum("Angled","Vertical") var type = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == 0:
		$VeritcalCollison.disabled = true
		$VeritcalCollison.visible = false
		$Sprite2D.frame = 0
	else:
		$AngledCollision.disabled = true
		$AngledCollision.visible = false
		$Sprite2D.frame = 4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
