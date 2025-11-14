extends Node2D

#Handle the following logic for the Tornado in Sky Chase Zone and Wing Fortress.

## If false, the player cannot control the Tornado.
@export var allow_player_steering = true

var player: Player2D = null
@onready var tornado = get_node("Tornado")
@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Global.players[0]
	tornado.plane_damaged.connect(tornado_damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(tornado):
		if tornado.global_position.y > Global.hardBorderBottom:
			tornado.queue_free()
			player = null
			queue_free()
	else:
		player = null
		queue_free()
	
	if !player:
		return

	if allow_player_steering:
		global_position.x = player.global_position.x - 32
		var camera = player.camera
		if Global.stageClearPhase > 0:
			global_position.x = move_toward(global_position.x,camera.limit_left+160,delta*128)
			player.position.x = global_position.x+32

		if player.movement.y < 0:
			global_position.y += delta*64
		elif player.movement.y > 0:
			global_position.y -= delta*32
	
		if player.currentState != player.STATES.SPINDASH:
			global_position.y += player.inputs[1]*(delta*64)
			global_position.y = round(global_position.y)
			
			if player.ground and player.inputs[1] != 0 and tornado.standing_players.has(player):
				player.position.y = global_position.y - 11
				player.verticalSensorMiddle.force_raycast_update()
				## Shitty hackish way of doing it
				for i in 8:
					if!player.verticalSensorMiddle.is_colliding():
						player.global_position.y += 1
						player.verticalSensorMiddle.force_raycast_update()
		global_position.y = clamp(global_position.y,camera.limit_top + 40,camera.limit_bottom - 64)
	else:
		player.position.x = global_position.x + 32
	
	if parent is PathFollow2D:
		var this: PathFollow2D = parent
		if this.progress_ratio >= 1.0 and player:
			player = null

func tornado_damage():
	allow_player_steering = false
	player = null
	
