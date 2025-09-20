extends Area2D

## If true, align the player to the center of the bar.
@export var setCenter = true
## Allow directional input on this vine/bar
@export var directional_input = true
## Optionally set sound to play when making contact
@export var grabSound = preload("res://Audio/SFX/Player/s2br_Grab.wav")

## Players hanging onto the vine
var players: Array[Player2D] = []

const HANG_OFFSET = 20

func _ready():
	$Grab.stream = grabSound

func _process(delta: float) -> void:
	for body in players:
		if body.poleGrabID == self:
			body.global_position.y = global_position.y + HANG_OFFSET
			if body.inputActions[body.INPUTS.XINPUT]:
				body.direction = sign(body.INPUTS.XINPUT)
			if body.any_action_pressed():
				_player_jumpoff(body)

func _player_jumpoff(body:Player2D):
	if players.has(body):
		body.animator.play("hang")
		body.set_state(body.STATES.AIR)
		body.movement.x = 120*body.direction
		body.movement.y = -240
		body.allowTranslate = false
		body.poleGrabID = null
		players.erase(body)

# All that happens in phyhsics process is the player checks 
func _physics_process(delta: float) -> void:
	for body in players:
		if (!body.poleGrabID and 
		body.movement.y > 0 and 
		body.global_position.y > global_position.y and 
		!body.controlObject):
			body.poleGrabID = self
			if setCenter:
				body.global_position.x = global_position.x
			body.movement = Vector2.ZERO
			body.allowTranslate = true
			body.animator.play("hang")
			body.set_state(body.STATES.HANG,body.currentHitbox.NORMAL)
			$Grab.play


func _on_body_entered(body: Player2D) -> void:
	players.append(body)


func _on_body_exited(body: Player2D) -> void:
	if !body.poleGrabID == self:
		players.erase(body)
	if body.poleGrabID == self && body.currentState != body.STATES.HANG:
		body.poleGrabID = null
		body.allowTranslate = false
		players.erase(body)
