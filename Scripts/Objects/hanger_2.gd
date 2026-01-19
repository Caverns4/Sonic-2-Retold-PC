extends Area2D

## If true, align the player to the center of the bar.
@export var setCenter: bool = true
## Allow directional input on this vine/bar
@export var directional_input: bool = true
## Optionally set sound to play when making contact
@export var grabSound = preload("res://Audio/SFX/Player/s2br_Grab.wav")
## Press down to drop off the object instead of jump.
@export var press_down_to_drop: bool = true
## Not yet implimented
@export var player_can_shimmy: bool = false

## Players hanging onto the vine
var players: Array[Player2D] = []
## If set to true, some paramaters about the object will behave slightly differently.
var playerCarryAI: bool = false
var anim_name: String = "hang"

const HANG_OFFSET = 20

func _ready():
	$Grab.stream = grabSound
	if player_can_shimmy:
		anim_name = "hang2"

func _process(_delta: float) -> void:
	for body:Player2D in players:
		if body.poleGrabID == self and playerCarryAI == true:
			if $HitBox.disabled == true or body.is_on_floor() or body.is_on_wall():
				_player_dropoff(body)

func _player_jumpoff(body:Player2D):
	if players.has(body):
		body.animator.play(anim_name)
		body.set_state(body.STATES.AIR)
		body.air_control = true
		body.movement.x = 120*body.direction
		body.movement.y = -240
		body.allowTranslate = false
		body.poleGrabID = null
		_disconnect_player(body)

func _player_dropoff(body:Player2D):
	if players.has(body):
		body.set_state(body.STATES.AIR)
		body.air_control = true
		body.allowTranslate = false
		body.poleGrabID = null
		_disconnect_player(body)

## Remove the player from this object's detection.
func _disconnect_player(body):
	players.erase(body)

# All that happens in phyhsics process is the player checks 
func _physics_process(_delta: float) -> void:
	for body:Player2D in players:
		if body.poleGrabID == self:
			if setCenter or playerCarryAI:
				body.global_position.x = global_position.x
				body.cam_update()
			body.global_position.y = global_position.y + HANG_OFFSET
			if body.any_action_pressed():
				if player_can_shimmy:
					_player_dropoff(body)
				else:
					_player_jumpoff(body)
			
			if directional_input or player_can_shimmy:
				var dir = body.get_x_input()
				if dir:
					body.direction = sign(dir)
					body.sprite.flip_h = (body.direction < 0)
				if player_can_shimmy:
					body.movement.x = 120*dir
					var anim = "hangShimmy" if body.movement.x != 0 else anim_name
					body.animator.play(anim)
			
			if (body.is_down_held() and press_down_to_drop):
				_player_dropoff(body)
		
		# initial hook
		if (!body.poleGrabID and body.movement.y > 0 and 
		body.global_position.y > global_position.y and 
		!body.controlObject):
			body.poleGrabID = self
			if setCenter and !player_can_shimmy:
				body.global_position.x = global_position.x
			body.movement = Vector2.ZERO
			body.allowTranslate = true
			body.animator.play(anim_name)
			body.set_state(body.STATES.HANG,body.currentHitbox.NORMAL)
			$Grab.play()


# Returns the count of players contacting with the hanger. Used by external scripts.
func get_contacting_players():
	var count: Array = []
	for i:Player2D in players:
		if i.poleGrabID == self:
			count.append(i)
	return count


func _on_body_entered(body: Player2D) -> void:
	var parent = get_parent()
	if body != parent:
		players.append(body)


func _on_body_exited(body: Player2D) -> void:
	if !body.poleGrabID == self:
		_disconnect_player(body)
	if body.poleGrabID == self && (body.currentState != body.STATES.HANG or player_can_shimmy):
		body.set_state(body.STATES.AIR)
		body.air_control = true
		body.poleGrabID = null
		body.allowTranslate = false
		_disconnect_player(body)
