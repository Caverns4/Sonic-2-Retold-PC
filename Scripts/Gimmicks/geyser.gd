extends Node2D

# Any player in PlayerOverlap gets pushed in the
# direction of this object's rotation with a minimum speed of Vectr2.UP * 6.
# This movement is done by modifying velocity, not translation.

#PlayerEntry is just a simple sensor to trigger the effect when the field is entered.

const WAIT_TIME = 4.0 #seconds before the funnel expires.

@export var minimumVelocity = 6 #(*60.delta)
@export var length = 64 #Extension behind the object's "head"

@onready var playerEntry = $PlayerEntry
@onready var geyser = $PlayerOverlap

var triggers = []
var players = [] # Nodes
var velocityPreVec = Vector2.ZERO #Movement speed before Vector is rortated
var trigger = false
var waitTime = 0.0
var frameTimer = 0.0

func _ready() -> void:
	velocityPreVec.y = 0-max(1*60,minimumVelocity*60)

func _physics_process(delta: float) -> void:
	if triggers and !trigger:
		trigger = true
	elif !triggers and trigger:
		trigger = false
		waitTime = WAIT_TIME
	
	frameTimer += (delta * (60))
	$PlayerOverlap/GeyserTopSprite.frame = wrap(round(frameTimer/3.0),0,3)
	$PlayerOverlap/GeyserLongSprite.frame = wrap(round(frameTimer/3.0),0,3)
	UpdatePosition(delta)

	for i in players.size():
		if players[i].animator:
			players[i].movement = Vector2(velocityPreVec).rotated(rotation)
			players[i].animator.play("hurt")

func UpdatePosition(delta):
	if !trigger and waitTime > 0.0:
		waitTime -= delta
	
	if trigger or waitTime > 0.0:
		geyser.position.y = max(geyser.position.y-(delta*240), 0-(64+length))
	else:
		geyser.position.y = min(geyser.position.y+(delta*240),0)
		
	if geyser.position.y == 0:
		$PlayerOverlap.visible = false
	else:
		$PlayerOverlap.visible = true


func _on_player_entry_body_entered(body: Node2D) -> void:
	triggers.append(body)

func _on_player_entry_body_exited(body: Node2D) -> void:
	triggers.erase(body)


func _on_player_overlap_body_entered(body: Node2D) -> void:
	players.append(body)


func _on_player_overlap_body_exited(body: Node2D) -> void:
	players.erase(body)
