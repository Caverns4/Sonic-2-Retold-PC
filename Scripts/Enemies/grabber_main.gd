extends Node2D

const SPEED = 60

@onready var badnik = $GrabberEnemy
@onready var scanner = $Scan_Range

## Total distance travelled in pixels
@export var x_range: int = 128
## String Length
@export var y_range: int = 96
@onready var origin: Vector2 = global_position

var side: int = -1
var target_pos: Vector2 = Vector2.ZERO
var string_length: float = 0.0

enum STATES{IDLE,GRAB,HOLD}
var state = STATES.IDLE
var state_timer: float = 0.0

## The currently targetted player, if one is found 
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	origin = global_position
	$VisibleOnScreenEnabler2D.visible = true
	var direction = Vector2(x_range*clamp(side,-1,0),0)
	target_pos = origin + direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !badnik:
		return

	match state:
		STATES.IDLE:
			string_length = move_toward(string_length,0,32*delta)
			if !string_length:
				UpdateMotion(delta)
			if player:
				state = STATES.GRAB
				%ClawsBack.frame = 6
				%ClawsFront.frame = 4
		STATES.GRAB:
			string_length = move_toward(string_length,y_range,32*delta)
			if !player:
				state = STATES.IDLE
				%ClawsBack.frame = 5
				%ClawsFront.frame = 3
	#Update Badnik Sprite
	badnik.position.y = round(string_length)
	$String.size.y = round(string_length)


func UpdateMotion(delta):
	# move position toward origin point with the travel distance
	if side <= 0:
		position = position.move_toward(
			origin-Vector2(x_range,0),
			SPEED*delta)
	else:
		position = position.move_toward(origin,SPEED*delta)
	# if at the destination point then turn around
	
	if position.distance_to(target_pos) <= 1:
		badnik.scale.x = -badnik.scale.x
		#Calculate a new Target position
		side = -side
		if side <= 0:
			target_pos = origin + Vector2(x_range*clamp(side,-1,0),0)
		else:
			target_pos = origin
	else:
		calc_dir()
	# count down cool down
	if state_timer > 0:
		state_timer -= delta

func calc_dir():
	# calculate direction based on side movement and rotation
	var getDir = sign(Vector2(side,0).x)
	# check that it's not 0 so it doesn't become invisible
	if getDir != 0:
		badnik.scale.x = -getDir


func _on_scan_range_body_entered(body: Node2D) -> void:
	if !player:
		player = body


func _on_scan_range_body_exited(body: Node2D) -> void:
	if player == body:
		player = null
