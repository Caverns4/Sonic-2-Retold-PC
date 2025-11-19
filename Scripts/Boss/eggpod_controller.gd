extends Node2D

## The decoys still flying around Eggman.
@onready var children = get_children()
## The decoys eggman has already dropped, if still alive.
var decoys: Array[CharacterBody2D] = []

var timer: float = 0.0

## Target values.
var target_radius: float = 32
var target_speed: float = 3.0
var target_bulge: float = 0.5

## CURRENT values.
var orbit_radius: float = 32
var orbit_speed: float = 3.0
var orbit_bulge: = 0.5

func _ready() -> void:
	get_parent().got_hit.connect(_on_eggman_damaged)
	children = get_children()
	var count = get_child_count(true)
	var xOffset = 0.0
	for i in count:
		xOffset += (360.0/(count+1))
		children[i].angle = xOffset


func _process(delta: float) -> void:
	if decoys:
		var rebuild: Array[CharacterBody2D] = []
		for i in decoys:
			if is_instance_valid(i):
				rebuild.append(i)
			decoys = rebuild
	
	if !children:
		return
	timer += delta
	orbit_radius = move_toward(orbit_radius,target_radius,delta*32)
	orbit_speed = move_toward(orbit_speed,target_speed,delta*32)
	orbit_bulge = move_toward(orbit_bulge,target_bulge,delta*32)
	
	var bulge = sin(timer * 1.0)
	var dynamic_bulge = orbit_bulge + bulge
	var axis_angle = timer * 3.0

	for orb in children:
		if orb is CharacterBody2D:
			var angle: float= orb.angle + timer * orbit_speed
			var local := Vector2(
				cos(angle) * orbit_radius* dynamic_bulge,
				sin(angle) * orbit_radius)
			local = local.rotated(axis_angle)
			orb.position = local
			orb.z_index = 3 + int(local.x)
			orb.position = local + global_position



func _on_eggman_damaged():
	if children:
		var decoy = children.pop_back()
		decoy.break_away()
		decoys.push_front(decoy)
