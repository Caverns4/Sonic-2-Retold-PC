extends Area2D

@export var special_exit = false
@export var special_exit_zone = 0 as Global.ZONES

var player = null
var getCam = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.two_player_mode:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == Global.players[0] and Global.stageClearPhase == 0:
		monitoring = false
		if special_exit:
			Global.special_exit = special_exit_zone
		# func stage_clear()
		var currentTheme = SoundDriver.themes[SoundDriver.THEME.RESULTS]
		SoundDriver.playMusic(currentTheme)
		Global.stageClearPhase = 3
		getCam = body.camera
		#if getCam is Camera2D:
		#	getCam.limit_left = getCam.global_position.x
		#	getCam.limit_right = getCam.global_position.x
		#	getCam.limit_top = getCam.global_position.y
		#getCam.limit_bottom = getCam.global_position.y
		for i in Global.players:
			i.playerControl = -1
			# set inputs to right
			i.inputs[i.INPUTS.XINPUT] = 0
			i.inputs[i.INPUTS.YINPUT] = 0
			i.inputs[i.INPUTS.ACTION] = 0
