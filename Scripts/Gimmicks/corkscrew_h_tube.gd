extends Node2D

# TODO: Check animation

const SPEED = 6
const AMPLITUDE = 36

# length of the corkscrew
@export var length = 1

# player tracking array struct
# Array of [player,landed,wave_timer]
var playerList: Array = []

func _ready() -> void:
	scale.x = length

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	for i in playerList:
		var player: Player2D = i[0]
		if player.ground and !i[1]:
			i[1] = true
			player.allowTranslate = true
			i[2] = AMPLITUDE*SPEED
			player.set_state(player.STATES.CORKSCREW)
		#If the players has landed in the object.
		if i[1]:
			i[2] += delta
			var offset = sin(i[2]*SPEED) * AMPLITUDE
			player.position.y = position.y + offset
			player.camera.position.y = player.position.y
			if (player.direction > 0):
				player.animator.play("corkScrew")
			else:
				player.animator.play("corkScrewOffset")
			if player.movement.y < 0:
				player.movement.y = 0
				player.allowTranslate = false
				i[2] = 0.0
				i[1] = false
			var animSize = player.animator.current_animation_length
			player.animator.advance(
				-player.animator.current_animation_position
				+ animSize-(i[2])
				* animSize)
			
		i = [i[0],i[1],i[2]]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player2D:
		playerList.insert(playerList.size(),[body,false,0.0])
		body.controlObject = self


func _on_area_2d_body_exited(body: Node2D) -> void:
	for list in playerList:
		if list[0] == body:
			playerList.erase(list)
			body.allowTranslate = false
			body.controlObject = null
			body.set_state(body.STATES.AIR)
