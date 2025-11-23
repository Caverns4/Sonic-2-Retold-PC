extends StaticBody2D

@export var power: float = 360
@export var move_distance: Vector2 = Vector2.ZERO
@export var move_speed: float = 30.0

@onready var home: Vector2 = global_position

## Because I lacked the forsight to use a Characterbody or something
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	velocity.x = sign(move_distance.x)*move_speed
	velocity.y = sign(move_distance.y)*move_speed

func _physics_process(delta: float) -> void:
	if velocity:
		global_position += (velocity*delta)
		if abs(global_position.x - home.x) > move_distance.x:
			velocity.x = move_speed * sign(home.x - global_position.x)
		if abs(global_position.y - home.y) > move_distance.y:
			velocity.y = move_speed * sign(home.y - global_position.y)

func physics_collision(body, _hitVector):
	var col = body.objectCheck.get_collision_normal()
	if col:
		body.movement = (col.normalized()*power)
		$BumperSFX.play()
