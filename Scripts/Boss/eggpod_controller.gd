extends Node2D

## The decoys still flying around Eggman.
@onready var children = get_children()
var child_count: int = 0
## The decoys eggman has already dropped, if still alive.
var decoys: Array[CharacterBody2D] = []

var timer: float = 0.0

var target_radius: float = 48
var target_speed: float = 3.0

## Distance the particles should orbit at.
var orbit_radius: float = 48
## Speed of the particles to move.
var orbit_speed: float = 3.0
## The eccentricity of the orbit. 1.0 would be a perfect circle.
var orbit_roundness: float = 1.0
## Turn the oject's rotation to this, gives the objects its erratic motion.
var orbit_angle: float = 0.0

func _ready() -> void:
	get_parent().got_hit.connect(_on_eggman_damaged)
	children = get_children()
	child_count = get_child_count(true)


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

	orbit_speed = move_toward(orbit_speed,target_speed,delta*8)
	orbit_radius = move_toward(orbit_radius,target_radius,delta*8)

	var bulge = sin(timer*0.5*orbit_roundness)
	var z_rot = Vector2(bulge,-1.0+bulge).normalized()
	orbit_angle = wrapf(orbit_angle+delta*2,0,360)
	z_rot = z_rot.rotated(orbit_angle)

	var direction = Vector2.RIGHT
	var xOffset = 0.0
	for i in child_count:
		if i < children.size():
			direction = Vector2.RIGHT.rotated((deg_to_rad(fmod(xOffset + (Global.globalTimer * (orbit_speed * 60)),360))))
			xOffset += (360.0/(child_count))
			var local_pos = (direction * orbit_radius).round()
			children[i].position = local_pos * z_rot
			local_pos = local_pos
			children[i].z_index = z_index + int(local_pos.y)

func _on_eggman_damaged():
	if children:
		var decoy = children.pop_back()
		decoy.break_away()
		decoys.push_front(decoy)
		for i in children:
			i.disable_collision_after_damage()
