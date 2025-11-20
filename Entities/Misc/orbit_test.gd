extends Sprite2D

## The decoys still flying around Eggman.
@onready var children = get_children()
var child_count: int = 0

var timer: float = 0.0

## Distance the particles should orbit at.
@export var orbit_radius: float = 32
## Speed of the particles to move.
@export var orbit_speed: float = 3.0
## The eccentricity of the orbit. 1.0 would be a perfect circle.
@export var orbit_roundness: float = 1.0
## Turn the oject's rotation to this, gives the objects its erratic motion.
var orbit_angle: float = 0.0

func _ready() -> void:
	children = get_children()
	child_count = get_child_count(true)

func _process(delta: float) -> void:
	if !children:
		return
	timer += delta
	
	# Debug controls
	if Input.is_action_pressed("gm_up"):
		orbit_speed += delta
	if Input.is_action_pressed("gm_down"):
		orbit_speed -= delta
	if Input.is_action_pressed("gm_right"):
		orbit_radius += delta*8
	if Input.is_action_pressed("gm_left"):
		orbit_radius -= delta*8
	if Input.is_action_just_pressed("gm_super"):
		if get_child_count() > 0:
			children.erase(get_child(0))
			get_child(0).free()
	
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
