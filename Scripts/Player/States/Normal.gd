extends PlayerState

var skid = false
# timer for looking up and down
# the original game uses 120 frames before panning over, so multiply delta by 0.5 for the same time
var lookTimer = 0
var actionPressed = false

# player idle animation array
# first array is player ID (Sonic, Tails, Knuckles), second array is the idle number
# note: idle is always played first
# you'll want to increase this for the number of playable characters
var playerIdles = [
# SONIC
["idle1","idle1","idle1","idle2","idle3"],
# TAILS
["idle1"],
# KNUCKLES
["idle1"],
# AMY
["idle1","idle1","idle1","idle1","idle1","idle1","idle1","idle1","idle2","idle3"], # Note: like Tails, Amy loops on idle3
# MIGHTY
["idle1","idle2","idle3","idle4","idle5"],
# RAY
["idle1","idle1","idle1","idle2","idle3"],
# SONIC_BETA
["idle1","idle1","idle1","idle2","idle3"]
]

func state_exit():
	skid = false
	parent.get_node("HitBox").position = parent.hitBoxOffset.normal
	parent.get_node("HitBox").shape.size = parent.currentHitbox.NORMAL
	
	lookTimer = 0
	parent.sfx[29].stop()

func _process(delta):
	
	# jumping / rolling and more (note, you'll want to adjust the other actions if your character does something different)
	if parent.jumpBuffer > 0: #any_action_pressed():
		if (parent.movement.x == 0 and parent.inputs[parent.INPUTS.YINPUT] > 0):
			parent.animator.play("spinDash")
			parent.sfx[2].play()
			parent.sfx[2].pitch_scale = 1
			parent.spindashPower = 0
			parent.animator.play("spinDash")
			parent.set_state(parent.STATES.SPINDASH)
		# peelout (Sonic only)
		#elif (parent.movement.x == 0 and parent.inputs[parent.INPUTS.YINPUT] < 0 and parent.character == Global.CHARACTERS.SONIC):
		#	parent.sfx[2].play()
		#	parent.sfx[2].pitch_scale = 1
		#	parent.spindashPower = 0
		#	parent.set_state(parent.STATES.PEELOUT)
		else:
			if !parent.check_for_ceiling():
				# reset animations
				parent.animator.play("RESET")
				parent.action_jump()
				parent.set_state(parent.STATES.JUMP)
		return null
	
	if parent.ground and !skid:
		if parent.movement.x == 0:
			
			var balancing = false
			# edge checking
			# set vertical sensors to check for objects
			var maskMemory = [parent.verticalSensorLeft.collision_mask,parent.verticalSensorRight.collision_mask]
			parent.verticalSensorLeft.set_collision_mask_value(13,true)
			parent.verticalSensorRight.set_collision_mask_value(13,true)
			
			var getL = parent.verticalSensorLeft.is_colliding()
			var getR = parent.verticalSensorRight.is_colliding()
			var getM = parent.verticalSensorMiddle.is_colliding()
			var getMEdge = parent.verticalSensorMiddleEdge.is_colliding()
			
			parent.verticalSensorLeft.collision_mask = maskMemory[0]
			parent.verticalSensorRight.collision_mask = maskMemory[1]
			
			# flip sensors
			if parent.direction < 0:
				getL = getR
				getR = parent.verticalSensorLeft.is_colliding()
			
			if !getM:
				#If a balance animation should play:
				match (parent.character):
					Global.CHARACTERS.SONIC: #default
						# super edge
						if parent.isSuper and parent.animator.has_animation("edge_super"):
							parent.animator.play("edge_super")
							balancing = true
						# normal edge
						elif !getR and getL and getMEdge:
							parent.animator.play("edge1")
							balancing = true
						# reverse edge
						# Bug: This should always get overridden by Edge2
						elif (!getL and getR):
							parent.animator.play("edge3")
							balancing = true
						# far edge
						elif !getMEdge:
							parent.animator.play("edge2")
							balancing = true
							if parent.verticalSensorLeft.is_colliding():
								parent.direction = 1
							elif parent.verticalSensorRight.is_colliding():
								parent.direction = -1
					
					Global.CHARACTERS.KNUCKLES:
						if (
						parent.animator.current_animation != "edge1" and 
						parent.animator.current_animation != "edge2"):
							parent.animator.play("edge1")
							parent.animator.queue("edge2")
							balancing = true
					_:
						#normal edge
						if (!getR and getL):
							parent.animator.play("edge1")
							balancing = true
						#reverse edge
						elif (!getL and getR):
							parent.animator.play("edge2")
							balancing = true
			
			if (parent.inputs[parent.INPUTS.YINPUT] > 0) and !balancing:
				lookTimer = max(0,lookTimer+delta*0.5)
				if parent.lastActiveAnimation != "crouch":
					parent.animator.play("crouch")
				balancing = true
			elif (parent.inputs[parent.INPUTS.YINPUT] < 0) and !balancing:
				lookTimer = min(0,lookTimer-delta*0.5)
				
				if(parent.isSuper and parent.character == Global.CHARACTERS.SONIC):
					if parent.lastActiveAnimation != "lookUp_Super":
						parent.animator.play("lookUp_Super")
				else:
					if parent.lastActiveAnimation != "lookUp":
						parent.animator.play("lookUp")
				balancing = true
			else:
				# reset look timer
				lookTimer = 0
				
			# Idle pose animation
			if !balancing:
				# No edge detected
				if getM or !parent.ground or parent.angle != parent.gravityAngle:
					# Play default idle animation
					if parent.isSuper and parent.animator.has_animation("idle_super"):
						parent.animator.play("idle_super")
					else:
						
						# loop through idle animations to see if there is an idle match
						var matchIdleCheck = false
						for i in playerIdles[parent.character-1]:
							if parent.lastActiveAnimation == i:
								matchIdleCheck = true
						
						if parent.lastActiveAnimation != "idle" and !matchIdleCheck or !parent.animator.is_playing():
							parent.animator.play("idle")
							# queue player specific idle animations
							for i in playerIdles[parent.character-1]:
								parent.animator.queue(i)
		#Non-idle cases
		elif sign(parent.pushingWall) == sign(parent.movement.x) and parent.pushingWall != 0:
			parent.animator.play("push")
		elif(abs(parent.movement.x) < 6*60):
			parent.animator.play("walk")
		elif(abs(parent.movement.x) < 10*60):
			parent.animator.play("run")
		else:
			parent.animator.play("peelOut")
	
	if parent.lastActiveAnimation == "crouch":
		parent.get_node("HitBox").position = parent.hitBoxOffset.crouch
		parent.get_node("HitBox").shape.size = parent.currentHitbox.CROUCH
	else:
		parent.get_node("HitBox").position = parent.hitBoxOffset.normal
		parent.get_node("HitBox").shape.size = parent.currentHitbox.NORMAL
	
	if parent.inputs[parent.INPUTS.XINPUT] != 0 and !skid:
		parent.direction = parent.inputs[parent.INPUTS.XINPUT]
	elif parent.movement.x != 0 and skid:
		parent.direction = sign(parent.movement.x)
	
	# water running
	parent.action_water_run_handle()
	

func _physics_process(delta):
	
	# rolling
	if (parent.inputs[parent.INPUTS.YINPUT] == 1 and parent.inputs[parent.INPUTS.XINPUT] == 0 and abs(parent.movement.x) > 0.5*60):
		parent.set_state(parent.STATES.ROLL)
		parent.animator.play("roll")
		parent.sfx[1].play()
		return null
	
	# set air state
	if (!parent.ground):
		parent.set_state(parent.STATES.AIR)
		#Stop script
		return null
	
	# skidding
	if !skid and sign(parent.inputs[parent.INPUTS.XINPUT]) != sign(parent.movement.x) and abs(parent.movement.x) >= 5*60 and parent.inputs[parent.INPUTS.XINPUT] != 0 and parent.horizontalLockTimer <= 0:
		skid = true
		parent.sfx[19].play()
		parent.animator.play("skid")
		$"../../SkidDustTimer".start(0.1)
	
	elif skid:
		var inputX = parent.inputs[parent.INPUTS.XINPUT]
		
		if round(parent.movement.x/200) == 0 and sign(inputX) != sign(parent.movement.x):
			if parent.animator.has_animation("skidTurn"):
				parent.animator.play("skidTurn")
		
		if !parent.animator.is_playing() or inputX == sign(parent.movement.x):
			skid = (round(parent.movement.x) != 0 and inputX != sign(parent.movement.x) and inputX != 0)
		
	
	parent.sprite.flip_h = (parent.direction < 0)
	
	parent.movement.y = min(parent.movement.y,0)
	
	# Camera look
	if abs(lookTimer) >= 1:
		parent.camLookAmount += delta*4*sign(lookTimer)

	var calcAngle = rad_to_deg(parent.angle-parent.gravityAngle)
	calcAngle = wrapf(calcAngle,0,360)
	
	# Apply slope factor
	if (calcAngle >= 46 and calcAngle <= 315) or parent.movement.x !=0:
		parent.movement.x += (parent.slp*sin(parent.angle-parent.gravityAngle))/GlobalFunctions.div_by_delta(delta)
	
		# if speed below fall speed, slide down slopes and maybe also drop
	if (abs(parent.movement.x) < parent.fall and (calcAngle >= 46 and calcAngle <= 315)):
		if (round(calcAngle) >= 90 and round(calcAngle) <= 270):
			parent.disconect_from_floor()
		parent.groundSpeed = 0
		parent.horizontalLockTimer = 30.0/60.0
		
	# movement
	parent.action_move(delta)


func _on_SkidDustTimer_timeout():
	if parent.currentState == parent.STATES.NORMAL:
		if !skid:
			$"../../SkidDustTimer".stop()
		else:
			var dust = parent.Particle.instantiate()
			dust.play("SkidDust")
			dust.global_position = parent.global_position+(Vector2.DOWN*16).rotated(deg_to_rad(parent.spriteRotation-90))
			parent.get_parent().add_child(dust)
