@tool
extends EnemyBase


@export var orbs = 4
@export var speed = -100
@export var moveSpeed = -10
@export var distance = 20
var spinOffset = 0
@export var launchOrbs = false

@onready var orbList = [get_node("Orb")]

func _ready():
	if !Engine.is_editor_hint():
		# initial velocity
		velocity.x = moveSpeed
		# set scale based on direction
		if moveSpeed != 0:
			scale.x = sign(-velocity.x)*abs(scale.x)
		
		# create duplicates of the surrounding orbs based on the total
		for _i in range(orbs-1):
			var newOrb = $Orb.duplicate()
			add_child(newOrb)
			orbList.append(newOrb)
		
		$VisibleOnScreenEnabler2D.visible = true

func _process(delta):
	if Engine.is_editor_hint():
		$Orb.position.y = -distance
	else:
		super(delta)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		# classic behaviour (just rotate the orbs, don't touch initial velocity)
		spinOffset += speed*delta
		# rotate the orbs based on spinOffset
		for i in range(orbList.size()):
			var getOrb = orbList[i]
			getOrb.position = (Vector2.RIGHT*distance).rotated(deg_to_rad(spinOffset+((360.0/orbs)*i)))
		# Launch base behaviour
