extends Area2D

@export var launch_speed: float = 12.0
@export var launch_height: float = 4

var player: Player2D = null

var direction: int = 1
@onready var home_pos: Vector2 = global_position

@onready var launch_timer: Timer = Timer.new()

func _ready() -> void:
	direction = sign(scale.rotated(rotation).x)
	launch_timer.one_shot = true
	add_child(launch_timer)

func _process(delta: float) -> void:
	if player: player.global_position = round(global_position) - Vector2(0-24*direction,20)

	if !launch_timer.is_stopped():
		global_position.x += delta*480*direction
	else:
		global_position.x = move_toward(global_position.x,home_pos.x,256*delta)

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D and !body.controlObject and !player:
		player = body
		player.set_state(player.STATES.ANIMATION)
		player.controlObject = self
		player.animator.play("Rider")
		player.movement = Vector2.ZERO
		await launch_player()

func launch_player() -> void:
	launch_timer.start(0.25)
	await launch_timer.timeout
	player.position.y -= 1
	player.movement.x = direction * (launch_speed*60)
	player.movement.y = 0-(abs(launch_height)*60)
	player.set_state(player.STATES.AIR)
	player.controlObject = null
	player = null
