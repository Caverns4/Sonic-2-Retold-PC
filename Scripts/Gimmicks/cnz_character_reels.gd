extends Node2D

#Function: Run the slots occasionally, picking random targets.
#Do the above until a signal is recieved to do a spin.
#The spin signal should have a predetermined outcome, so all slots are the same,
#thus the reward will always make sense.

enum SLOT{SONIC,TAILS,KNUCKLES,EGGMAN,RING,JACKPOT}

var slots = []
var slotTargets = [SLOT.SONIC,SLOT.TAILS,SLOT.KNUCKLES]
var slotOffsets = [SLOT.SONIC*32,SLOT.TAILS*32,SLOT.KNUCKLES*32]

var idleTimer = 5.0
var forceSpinTime = 3.0
var active = false #If this slot is in use by a Slot Cage

func _ready() -> void:
	slots = [$SlotA,$SlotB,$SlotC]
	Global.characterReels.append(self)


func _process(delta: float) -> void:
	forceSpinTime -= delta
	# If the slots are all aligned, wait.
	if (slotOffsets[1] == slotTargets[1]*32
	and slotOffsets[2] == slotTargets[2]*32
	and slotOffsets[2] == slotTargets[2]*32):
		idleTimer -= delta
	
	# Pick a new face for each slot
	if idleTimer <= 0.0 and !active:
		for i in slotTargets.size():
			slotTargets[i] = randi_range(0,SLOT.size())
		idleTimer = 5
		forceSpinTime = 3.0
	
	if  (slotOffsets[1] == slotTargets[1]*32
	and slotOffsets[2] == slotTargets[2]*32
	and slotOffsets[2] == slotTargets[2]*32) and active:
		for i in Global.slotMachines:
			if i.has_method("reward_player"):
				i.reward_player(slotTargets)
		active = false
		idleTimer = 5
	
	# Slots can only stop one at a time
	for i in slotOffsets.size():
		if forceSpinTime > 0.0:
			slotOffsets[i] = wrap((slotOffsets[i] - (delta*180)), 0.0, SLOT.size()*32)
		else:
			#Never let a real finised spinning until the prior real has finished
			if (
				round(slotOffsets[i]) != (slotTargets[i]*32)
				or (round(slotOffsets[i]) == wrap((slotTargets[i]*32),0,SLOT.size()*32)
				and round(slotOffsets[max(i-1,0)]) != (slotTargets[max(i-1,0)]*32))
				):
				slotOffsets[i] = (slotOffsets[i] - (delta*120))
				slotOffsets[i] = wrap(slotOffsets[i], 0.0, SLOT.size()*32)
			else:
				slotOffsets[i] = slotTargets[i]*32
		var node = slots[i]
		node.region_rect = Rect2(0,round(slotOffsets[i]),32,32)


func roll_character_slots(result: Array) -> void:
	active = true
	forceSpinTime = 3.0
	idleTimer = 5.0
	slotTargets = result
