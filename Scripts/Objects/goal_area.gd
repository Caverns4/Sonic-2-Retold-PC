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
	if body == Global.players[0] and !Global.stage_cleared:
		if special_exit:
			Global.special_exit = special_exit_zone
		Global.emit_stage_clear()
		camera = body.camera
		for i in Global.players:
			i.playerControl = -1
			i.inputs[i.INPUTS.XINPUT] = 0
			i.inputs[i.INPUTS.YINPUT] = 0
			i.inputs[i.INPUTS.ACTION] = 0
