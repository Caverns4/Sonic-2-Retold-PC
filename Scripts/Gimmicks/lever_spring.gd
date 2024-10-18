extends StaticBody2D


var players = []
var TotalWeight = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Sprite2D.frame != 0:
		$CollisionPolygon2D.scale.y = 0.4
	else:
		$CollisionPolygon2D.scale.y = 1.0
	
	
