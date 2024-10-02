@tool
extends EnemyBase


@export var orbs = 4
@export var speed = -100
@export var moveSpeed = -10
@export var distance = 20
var spinOffset = 0
@export var launchOrbs = false

@onready var orbList = [get_node("Orb")]
var orbStates = [false] #State of each orb in the array, if flung
var orblifeSpan = [0] #Time orb has been alive after firing.

var targets = []
var triggered = false

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
			orbStates.insert(orbStates.size(),false)
			orblifeSpan.insert(orblifeSpan.size(),0)
		
		$VisibleOnScreenEnabler2D.visible = true
		$PlayerCheck.visible = true

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
			if orbList[i]:
				var getOrb = orbList[i]
				if !orbStates[i]:
					getOrb.position = (Vector2.RIGHT*distance).rotated(deg_to_rad(spinOffset+((360.0/orbs)*i)))
				else:
					#getOrb.position.x += 0-(sign(speed) * (delta*60))
					getOrb.position.x -= sign(speed) * (delta*60)
					orblifeSpan[i]+=delta
			
				if orblifeSpan[i] > 6.0:
					getOrb.queue_free()
					orbList[i] = null
			
				if launchOrbs and triggered and !orbStates[i]:
					if round(getOrb.position.y * sign(speed)) == distance:
						orbStates[i] = true

func _on_player_check_body_entered(body: Node2D) -> void:
	targets.append(body)
	triggered = true


func _on_player_check_body_exited(body: Node2D) -> void:
	targets.erase(body)
