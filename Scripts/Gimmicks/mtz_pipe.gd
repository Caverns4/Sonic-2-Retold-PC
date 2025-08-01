extends Area2D

## Speed the players can move through the tube at.
@export var speed = 8
## Speed the player should move horizontally when exiting the tube.
@export var release_velocity = 0
## Sound to play when charging.
@export var charge_sfx = preload("res://Audio/SFX/Player/s2br_Roll.wav")
## Sound to play when the player is launched.
@export var release_sfx = preload("res://Audio/SFX/Player/s2br_DashRelease.wav")

@onready var path: Line2D = null
@onready var animator: AnimationPlayer = $AnimationPlayer

enum STATES{WAIT,ZOOM,RELEASE}
var state = STATES.WAIT

## Player Reference
var player: Player2D = null
## Current point in tube
var getPoint = 0
## Hover position of the player waiting in the tube
var hoverOffset: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children(false):
		if i is Line2D and !path:
			i.visible = false
			path = i
	if !path:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		STATES.WAIT:
			if player:
				updateHoveringPos(delta)
		STATES.ZOOM:
			if getPoint >= path.get_point_count():
				_free_player()
				return
			var target = path.global_position + path.get_point_position(getPoint)
			
			player.global_position = player.global_position.move_toward(target,speed*60*delta)
			if player.global_position == target:
				getPoint+=1

func updateHoveringPos(delta):
	# change the hover offset
	player.global_position.y = global_position.y+8-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	player.global_position.y = global_position.y+8+hoverOffset

func _on_body_entered(body: Player2D) -> void:
		if !player and state == STATES.WAIT and !body.controlObject:
			player = body
			getPoint = 1
			animator.play("Entry")
			SoundDriver.play_sound2(charge_sfx)
			body.global_position = global_position
			body.movement = Vector2.ZERO
			body.set_state(body.STATES.ANIMATION)
			body.animator.play("roll")
			body.animator.queue("roll")
			body.controlObject = self
			body.allowTranslate = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Entry":
		SoundDriver.play_sound(release_sfx)
		state = STATES.ZOOM

func _free_player():
	player.allowTranslate = false
	player.controlObject = null
	player.set_state(player.STATES.ROLL)
	player.movement.x = release_velocity*60
	player = null
	state = STATES.WAIT
	hoverOffset = 0
