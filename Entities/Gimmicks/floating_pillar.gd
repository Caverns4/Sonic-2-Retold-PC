extends AnimatableBody2D

#Behavior types:
#Static, Fall when stood on, Sink when stood on

@export_enum("static","fall","float")var behavior = 0

@onready var floorTest = $RayCast2D
var activated = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if activated:
		match behavior:
			1: # fall
				if !floorTest.is_colliding():
					global_position.y += 64*delta
			2: #Sink in water when stood on
				if !floorTest.is_colliding():
					global_position.y += 64*delta
			_: # Do nothing
				activated = false
	
	if behavior == 2:
		if global_position.y > Global.waterLevel and !activated:
			global_position.y -= 32*delta
		if global_position.y <= Global.waterLevel and !activated:
			global_position.y = Global.waterLevel
		activated = false

func physics_collision(body, hitVector):
	if hitVector.y > 0.0 and body.ground:
		activated = true
