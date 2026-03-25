extends PlayerState

# animation state

# this state is meant to be used generally to play animations

var offset: float = 0
var path: Node2D = null
var pipe: Node2D = null
var pipePoint: int = 0
var pipeDirection: int = 1

func _process(delta: float) -> void:
	# this state can be used for several purposes, pipe logic is a bit more complicated so I built some pipe following code here
	if pipe != null:
		# get next pipe point
		var point: Vector2 = pipe.global_position+pipe.get_point_position(pipePoint)
		# set movement
		parent.movement = parent.global_position.direction_to(point)
		parent.global_position = parent.global_position.move_toward(point,pipe.speed*60*delta)
		parent.allowTranslate = true
		
		# if nearing the end of the current path pipe check if to end or go to next pipe path
		var getPipeSpeed: float = pipe.speed
		while parent.global_position.distance_to(point) <= getPipeSpeed and pipe != null:
			# check if we're at the end of the path
			if pipePoint < pipe.get_point_count()-1:
				parent.global_position = point
				pipePoint += 1
				point = pipe.global_position+pipe.get_point_position(pipePoint)
			else:
				# release the player if no other point can be found
				parent.set_state(parent.STATES.ROLL)
				parent.movement = (point-(pipe.global_position+pipe.get_point_position(pipePoint-1))).normalized()*getPipeSpeed*60.0
				parent.global_position = point
				parent.allowTranslate = false
				parent.sfx[3].play()
				pipe = null
