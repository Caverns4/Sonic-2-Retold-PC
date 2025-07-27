extends Area2D

var charge_sfx = preload("res://Audio/SFX/Player/s2br_Roll.wav")
var release_sfx = preload("res://Audio/SFX/Player/s2br_DashRelease.wav")

@onready var path: Line2D = null
@onready var animator: AnimationPlayer = $AnimationPlayer

enum STATES{WAIT,ZOOM,RELEASE}
var state = STATES.WAIT

var player: Player2D = null
var hoverOffset = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children(false):
		if i is Line2D and !path:
			path = i
	if !path:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		STATES.WAIT:
			if player:
				updateHoveringPos(delta)

func updateHoveringPos(delta):
	# change the hover offset
	player.global_position.y = global_position.y+8-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	player.global_position.y = global_position.y+8+hoverOffset

func _on_body_entered(body: Player2D) -> void:
		if !player and state == STATES.WAIT:
			player = body
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
	player = null
