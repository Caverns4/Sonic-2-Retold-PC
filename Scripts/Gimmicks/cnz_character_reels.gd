extends Node2D


enum SLOT{SONIC,TAILS,KNUCKLES,EGGMAN,RING,JACKPOT}

var slots = []
var slotTargets = [SLOT.SONIC,SLOT.TAILS,SLOT.KNUCKLES]
var slotOffsets = [SLOT.SONIC*32,SLOT.TAILS*32,SLOT.KNUCKLES*32]

var idleTimer = 10.0
var active = false #If this slot is in use by a Slot Cage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slots = [$SlotA,$SlotB,$SlotC]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	idleTimer -= delta * 64
	if idleTimer <= 0.0 and !active:
		for i in slotTargets.size():
			slotTargets[i] = randi_range(0,SLOT.size())
		idleTimer = 10
	
	for i in slotOffsets.size():
		if round(slotOffsets[i]) != (slotTargets[i]*32):
			slotOffsets[i] = wrap((slotOffsets[i] + (delta*120)), 0.0, SLOT.size()*32)
		else:
			slotOffsets[i] = slotTargets[i]*32
		var node = slots[i]
		node.region_rect = Rect2(0,round(slotOffsets[i]),32,32)
