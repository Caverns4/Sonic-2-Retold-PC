extends Area2D

@export var special_exit = false
@export var special_exit_zone = 0 as Global.ZONES

var player: Player2D = null
var camera: Camera2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.two_player_mode:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == Global.players[0] and Global.stageClearPhase == 0:
		Main.can_pause = false
		monitoring = false
		if special_exit:
			Global.special_exit = special_exit_zone
		var currentTheme = SoundDriver.themes[SoundDriver.THEME.RESULTS]
		SoundDriver.playMusic(currentTheme)
		Global.stageClearPhase = 3
		camera = body.camera
		#if camera is Camera2D:
		#	camera.limit_left = camera.global_position.x
		#	camera.limit_right = camera.global_position.x
		#	camera.limit_top = camera.global_position.y
		#camera.limit_bottom = camera.global_position.y
		for i in Global.players:
			i.playerControl = -1
			i.inputs[i.INPUTS.XINPUT] = 0
			i.inputs[i.INPUTS.YINPUT] = 0
			i.inputs[i.INPUTS.ACTION] = 0
