extends Node2D

#Handle the following logic for the Tornado in Sky Chase Zone.

var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Global.players[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.x = player.global_position.x - 32
	
	var camera = player.camera
	
	if player.movement.y < 0:
		global_position.y += delta*64
	elif player.movement.y > 0:
		global_position.y -= delta*32
	
	var movePlayer = false
	if player.ground:
		movePlayer = true
	
	if player.currentState != player.STATES.SPINDASH:
		global_position.y += player.inputs[1]*(delta*32)
		if movePlayer:
			player.global_position.y += player.inputs[1]*(delta*32)
	
	#global_position.y = clamp(global_position.y,camera.limit_top + 40,camera.limit_bottom - 64)
