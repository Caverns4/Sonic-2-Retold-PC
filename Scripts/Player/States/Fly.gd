extends PlayerState

# Tails flight
var flightTime = 8*60
var flyGrav: float = 0.03125
var actionPressed: bool = true
var PartnerPriority: int = 0

var flyHitBox
var carryHitBox
var carryBox

var carried_partner: Player2D = null

func _ready():
	flyHitBox = parent.get_node("TailsFlightHitArea/HitBox")
	carryHitBox = parent.get_node("TailsCarryBox/HitBox")
	carryBox = parent.get_node("TailsCarryBox")

func state_activated():
	flightTime = 8
	flyGrav = 0.03125
	flyHitBox.disabled = false
	carryHitBox.disabled = false
	actionPressed = true
	
func state_exit():
	if carried_partner:
		carried_partner.z_index = clamp(parent.z_index+1,1,6)
		carryBox._player_dropoff(carried_partner)
		carried_partner.poleGrabID = null
		carried_partner = null
	
	flyHitBox.call_deferred("set","disabled",true)
	carryHitBox.call_deferred("set","disabled",true)
	# stop flight sound
	parent.sfx[21].stop()
	parent.sfx[22].stop()
	# delay sound stop, for some reason it bugs out sometimes
	if $FlyBugStop.is_inside_tree():
		$FlyBugStop.start(0.1)

func _process(_delta):
	# Animation
	if parent.is_in_water:
		if carried_partner:
			parent.animator.play("swimCarry")
		elif flightTime > 0:
			parent.animator.play("swim")
		else:
			parent.animator.play("swimTired")
	else:
		if flightTime > 0:
			if !carried_partner:
				parent.animator.play("fly")
			else:
				if parent.movement.y >= 0:
					parent.animator.play("flyCarry")
				else:
					parent.animator.play("flyCarryUP")
		else:
			parent.animator.play("tired")
	
	# flight sound (verify we are not underwater)
	if !parent.is_in_water:
		if flightTime > 0:
			if !parent.sfx[21].playing:
				parent.sfx[21].play()
		else:
			if !parent.sfx[22].playing:
				parent.sfx[21].stop()
				parent.sfx[22].play()
	else:
		parent.sfx[21].stop()
		parent.sfx[22].stop()
	

func _physics_process(delta):
	
	var player_memory = carried_partner
	var grabbing_characters = carryBox.get_contacting_players()
	if grabbing_characters:
		carried_partner = grabbing_characters[0]
		carried_partner.update_sensors()
		if carried_partner.verticalSensorMiddle.is_colliding():
			carryBox._player_dropoff(carried_partner)
			carried_partner = null
	
	if player_memory and !carried_partner:
		carryBox.playerCarryAI = false
		player_memory.z_index = parent.z_index+1
		player_memory = null
	
	if carried_partner:
		# set carried player direction
		carried_partner.direction = parent.direction
		carried_partner.sprite.flip_h = parent.sprite.flip_h
	
		# set immediate inputs if ai
		if parent.playerControl == 0:
			parent.inputs = carried_partner.inputs.duplicate()
			# Sonic 3 A.I.R. Hybrid Style - convert holding up into continual A presses while in AI mode
			if parent.is_up_held():
				parent.inputs[parent.INPUTS.ACTION] = 1
			carryBox.playerCarryAI = true
	
	# air movement
	if (parent.get_x_input() != 0):
		
		if (parent.movement.x*parent.get_x_input() < parent.top):
			if (abs(parent.movement.x) < parent.top):
				parent.movement.x = clamp(parent.movement.x+(parent.acc*2)/GlobalFunctions.div_by_delta(delta)*parent.get_x_input(),-parent.top,parent.top)
				
	# Air drag
	if (parent.movement.y < 0 and parent.movement.y > -parent.releaseJmp*60):
		parent.movement.x -= ((parent.movement.x / 0.125) / 256)*60*delta
	
	# Change parent direction
	if (parent.get_x_input() != 0):
		parent.direction = parent.get_x_input()
	#	if carriedPlayer:
	#		carriedPlayer.direction = parent.direction
	
	# set facing direction
	parent.sprite.flip_h = (parent.direction < 0)
	
	# Flight logic
	parent.movement.y += flyGrav/GlobalFunctions.div_by_delta(delta)
	
	flightTime -= delta
	# Button press
	if parent.movement.y >= -1*60 and flightTime > 0 and !parent.roof and parent.position.y >= parent.limitTop+16:
		if parent.any_action_held_or_pressed() and (!actionPressed or parent.get_y_input() < 0) and (!carried_partner or !parent.is_in_water):
			flyGrav = -0.125
	# return gravity to normal after velocity is less then -1
	else:
		flyGrav = 0.03125
	
	if parent.position.y < parent.limitTop+16:
		parent.movement.y = max(0,parent.movement.y)
	
	# set actionPressed to prevent input repeats
	actionPressed = parent.any_action_held_or_pressed()
	
	# Reset state if on ground
	if (parent.ground):
		parent.set_state(parent.STATES.NORMAL)


func _on_FlyBugStop_timeout():
	parent.sfx[21].stop()
	parent.sfx[22].stop()
