class_name SlotMachineManager
extends Node

enum SLOT{SONICX,TAILS,KNUCKLES,EGGMAN,RING,JACKPOT,SONIC}
# Because Sonic is at offset 0, a dup entry must be present or else he would simply never be reachable.

var all_slot_machines: Array[Node2D] = []
## The target position of each reel.
var slot_targets: Array = [SLOT.SONIC,SLOT.TAILS,SLOT.KNUCKLES]
var slot_offsets: Array = [SLOT.SONIC,SLOT.TAILS,SLOT.KNUCKLES]

const SPIN_TIME_ARRAY: Array[float] = [3,1,1]
const IDLE_TIME = 5.0

## The time remaining when the reel is in an idle state, not triggered and not moving.
var idle_timer: float = 0.0
## The time the reels are forced into a spinning state before they are allowed to settle.
var force_spin_times: Array[float] = [3,1,1]
## If this slot is in use by a Slot Cage.
var is_in_use = false
## If the machine was activated by the player, a slot cage is saved to since the OK to.
var slot_cage = null


func _ready() -> void:
	Global.characterReels = self
	force_spin_times = SPIN_TIME_ARRAY.duplicate(true)
	for child in get_children():
		if child.is_in_group("SlotMachine"):
			all_slot_machines.append(child)

func  _process(delta: float) -> void:
	# If the reals have reached a result already, don't do anything.
	if idle_timer > 0 and !slot_cage:
		idle_timer -= delta
		return
	# Decriment the spin timer for each reel
	for i in force_spin_times.size():
		if force_spin_times[i] > 0 or (round(slot_offsets[i]*8) != slot_targets[i]*8):
			force_spin_times[i] -= delta
			break
	# Roll reels until force_spin_timmes and the offset is correct.
	for i in slot_offsets.size():
		if (force_spin_times[i] > 0) or (round(slot_offsets[i]*8) != slot_targets[i]*8):
			if (force_spin_times[i] > 0):
				slot_offsets[i] += delta*4
			slot_offsets[i] += delta*4
			slot_offsets[i] = wrapf(slot_offsets[i],SLOT.SONICX,SLOT.SONIC)
		elif round(slot_offsets[i]*8) == slot_targets[i]*8:
			slot_offsets[i] = slot_targets[i]
	
	if force_spin_times[2] > 0.0:
		_setup_child_graphics(delta)
		return
	
	if slot_offsets == slot_targets:
		idle_timer = IDLE_TIME
		if slot_cage:
			if slot_cage.has_method("reward_player"):
				slot_cage.reward_player()
				slot_cage = null
				idle_timer = 999
		else:
			slot_targets = determine_each_slot()
			force_spin_times = SPIN_TIME_ARRAY.duplicate(true)
	
	_setup_child_graphics(delta)

## Update the slot machine's graphics to match the needed frames.
func _setup_child_graphics(delta):
	for this_machine in all_slot_machines:
		var slotpicID = 0
		for pic in this_machine.get_children(true):
			if pic is Sprite2D:
				pic.region_rect = Rect2(0,slot_offsets[slotpicID]*32,32,32)
				slotpicID += 1


func roll_character_slots(result: Array, user: Node2D) -> void:
	idle_timer = 0.0
	slot_cage = user
	is_in_use = true
	force_spin_times = [1,1,1]
	slot_targets = result


func determine_each_slot():
	var a = randi_range(1,SLOT.size()-1)
	var b = randi_range(1,SLOT.size()-1)
	var c = randi_range(1,SLOT.size()-1)
	var d = [a,b,c]
	return d
