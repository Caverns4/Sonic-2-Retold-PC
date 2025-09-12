extends Node2D

#Function: Run the slots occasionally, picking random targets.
#Do the above until a signal is recieved to do a spin.
#The spin signal should have a predetermined outcome, so all slots are the same,
#thus the reward will always make sense.

enum SLOT{SONIC,TAILS,KNUCKLES,EGGMAN,RING,JACKPOT}

var slots = []
## The target position of each reel.
var slotTargets = [SLOT.SONIC,SLOT.TAILS,SLOT.KNUCKLES]
var slotOffsets = [SLOT.SONIC*32,SLOT.TAILS*32,SLOT.KNUCKLES*32]

## The time remaining when the reel is in an idle state, not triggered and not moving.
var idleTimer: float = 5.0
## The time the reels are forced into a spinning state before they are allowed to settle.
var forceSpinTime: float = 3.0
## If this slot is in use by a Slot Cage.
var active = false
## If all 3 reels are at their target points.
var target_reached = false

func _ready() -> void:
	slots = [$SlotA,$SlotB,$SlotC]
	Global.characterReels.append(self)


func _process(delta: float) -> void:
	forceSpinTime -= delta
	if forceSpinTime > 0.0:
		for i in slotOffsets:
			i+=delta
		update_reel(delta)
		return
	
	# After Force Spin Timer expires, keep rolling intil Slot 1, 2, and 3 reach their target sequentially.
	
	if !active:
		# Wait til all the slots are aligned
		pass
	else:
		if  (slotOffsets[0]/32 == slotTargets[0]
		and slotOffsets[1]/32 == slotTargets[1]
		and slotOffsets[2]/32 == slotTargets[2]) and forceSpinTime <= 0:
			for i in Global.slotMachines:
				if i.has_method("DeterminPrize"):
					i.reward_player(slotTargets)
			active = false
			idleTimer = 5.0
	update_reel(delta)

func update_reel(delta):
	for i in slotOffsets.size():
			if (round(slotOffsets[i]) != (slotTargets[i]*32) or forceSpinTime > 0.0):
				var node = slots[i]
				slotOffsets[i] = wrap((slotOffsets[i] - (delta*180)), 0.0, SLOT.size()*32)
				node.region_rect = Rect2(0,round(slotOffsets[i]),32,32)
			else:
				var node = slots[i]
				node.region_rect = Rect2(0,round(slotTargets[i]*32),32,32)
	pass

func roll_character_slots(result: Array) -> void:
	active = true
	forceSpinTime = 3.0
	idleTimer = 5.0
	slotTargets = result
	print(slotTargets)
