@tool
extends StaticBody2D

## Red springs have more launch power than yellow springs.
@export_enum("Yellow", "Red") var type: int = 0:
	set(value):
		type = value
		set_spring()
	
@export_enum("Up", "Down", "Right", "Left", "Diagonal Up Right", "Diagonal Up Left", "Diagonal Down Right", "Diagonal Down Left") var spring_direction: int = 0:
	set(value):
		spring_direction = value
		set_spring()
## Kill transitional speed. If true, momentum no aligning with the launch direction will be haulted.
@export var kill_lateral_motion: bool = true
var hitDirection: Vector2 = Vector2.UP
var animList: Array[StringName] = ["SpringUp","SpringRight","SpringUpLeft","SpringUpRight"]
var animID: int = 0
const speed: Array[float] = [10,16]

var springTextures: Array[Texture2D] = [preload("res://Graphics/Gimmicks/springs_yellow.png"),preload("res://Graphics/Gimmicks/springs_red.png")]

@export_group("Effect Properties")
@export var spring_sfx: AudioStream = preload("res://Audio/SFX/Gimmicks/s2br_Spring.wav")

func set_spring() -> void:
	match (spring_direction):
		0, 1: # up, down
			$HitBox.disabled = false
			$DiagonalHitBox/AreaShape.disabled = true
			animID = 0
			$HitBox.rotation = deg_to_rad(0)
			scale = Vector2(1,1-(spring_direction*2))
			hitDirection = Vector2(0,-1+(spring_direction*2))
		2, 3: # right, left
			$HitBox.disabled = false
			$DiagonalHitBox/AreaShape.disabled = true
			animID = 1
			$HitBox.rotation = deg_to_rad(90)
			scale = Vector2(1-((spring_direction-2)*2),1)
			hitDirection = Vector2(1-((spring_direction-2)*2),0)
		4, 6: #diagonal right
			$HitBox.disabled = true
			$DiagonalHitBox/AreaShape.disabled = false
			animID = 3
			scale = Vector2(1,1-(spring_direction-4))
			# place super.normalized() at the end for CD physics
			hitDirection = scale*Vector2(1,-1)
		5, 7: #diagonal left
			$HitBox.disabled = true
			$DiagonalHitBox/AreaShape.disabled = false
			animID = 2
			scale = Vector2(1,1-(spring_direction-5))
			# place super.normalized() at the end for CD physics
			hitDirection = -scale
			
	$SpringAnimator.play(animList[animID])
	$SpringAnimator.advance($SpringAnimator.get_animation(animList[animID]).length)
	if $Spring.texture != springTextures[type]:
		$Spring.texture = springTextures[type]

# Collision check
func physics_collision(body: Player2D, hitVector: Vector2) -> void:
	# check that the players hit direction matches the direction we're facing (ignored for diagonal)
	if hitVector == -hitDirection:
		# do a Rock launch HAUGH!!!
		var setMove: Vector2 = hitDirection.rotated(rotation).rotated(-body.rotation).round()*speed[type]*60
		# vertical movement
		if setMove.y != 0:
			# disable ground
			body.ground = false
			body.set_state(body.STATES.AIR)
			body.air_control = true
			# figure out the animation based on the players current animation
			var curAnim: StringName = "walk"
			match(body.animator.current_animation):
				"walk", "run", "peelOut":
					curAnim = body.animator.current_animation
				# if none of the animations match and speed is equal beyond the players top speed, set it to run (default is walk)
				_:
					if(abs(body.groundSpeed) >= min(6*60,body.top)):
						curAnim = "run"
			# play player animation
			body.animator.play("spring")
			body.animator.queue(curAnim)
			# set vertical speed
			body.movement.y = setMove.y
			body.position.y = global_position.y + (hitDirection.y*32)
			body.set_state(body.STATES.AIR,body.currentHitbox.NORMAL)
			body.disconect_from_floor()
			if kill_lateral_motion == true:
				body.movement.x = 0
			$SpringAnimator.play(animList[animID])
			if $VisibleOnScreenNotifier2D.is_on_screen():
				SoundDriver.play_sound(spring_sfx)
		# horizontal movement
		else:
			# exit out of state on certain states
			#match(body.currentState):
			#	body.STATES.GLIDE:
			#		if !body.ground:
			#			body.animator.play("run")
			#			body.set_state(body.STATES.AIR)
			if body.ground:
				# set horizontal speed
				body.movement.x = setMove.x
				body.horizontalLockTimer = (15.0/60.0) # lock for 15 frames
				body.direction = sign(setMove.x)
				$SpringAnimator.play(animList[animID])
				if $VisibleOnScreenNotifier2D.is_on_screen():
					SoundDriver.play_sound(spring_sfx)
		
		# Disable pole grabs
		body.poleGrabID = null


func _on_Diagonal_body_entered(body:Player2D) -> void:
	# diagonal springs are pretty straightforward
	body.angle = body.gravityAngle
	body.set_state(body.STATES.AIR,body.currentHitbox.NORMAL)
	body.position.x = position.x
	body.position.y = position.y-8
	body.air_control = true
	body.movement = hitDirection*(speed[type]*60)
	$SpringAnimator.play(animList[animID])
	if (hitDirection.y < 0):
		body.set_state(body.STATES.AIR)
		# figure out the animation based on the players current animation
		var curAnim: StringName = "walk"
		match(body.animator.current_animation):
			"walk", "run", "peelOut":
				curAnim = body.animator.current_animation
			# if none of the animations match and speed is equal beyond the players top speed, set it to run (default is walk)
			_:
				if(abs(body.groundSpeed) >= min(6*60,body.top)):
					curAnim = "run"
		# play player animation
		body.animator.play("springScrew")
		body.animator.queue(curAnim)
	if $VisibleOnScreenNotifier2D.is_on_screen():
		SoundDriver.play_sound(spring_sfx)
	# Disable pole grabs
	body.poleGrabID = null
