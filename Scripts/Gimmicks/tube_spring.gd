extends StaticBody2D

@export_enum("Weak", "Strong") var power = 0 # The power of the spring when hopped on
@export var springSound = preload("res://Audio/SFX/Gimmicks/s2br_Spring.wav")

@onready var animator = $AnimationPlayer

var speed = [10.5,16]

enum STATES{CLOSED,OPEN,CLOSING}
var state = STATES.CLOSED

var players = [] #Detected players in the Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		STATES.CLOSED:
			if players.size() > 0:
				state = STATES.OPEN
				animator.play("OPEN")
		STATES.OPEN:
			if players.size() == 0:
				state = STATES.CLOSED
				animator.play("CLOSE")
		

func physics_collision(body, hitVector):
	if hitVector == Vector2.DOWN:
		var setMove =  Vector2.UP.round()*speed[power]*60
		# disable ground
		body.ground = false
		body.set_state(body.STATES.AIR)
		body.airControl = true
		#Setup Player animation
		var curAnim = "walk"
		match(body.animator.current_animation):
			"walk", "run", "peelOut":
				curAnim = body.animator.current_animation
			# if none of the animations match and speed is equal beyond the players top speed, set it to run (default is walk)
			_:
				if(abs(body.groundSpeed) >= min(6*60,body.top)):
					curAnim = "run"
		# play player animation
		body.animator.play("spring")
		body.animator.queue(curAnim)
		# set vertical speed
		body.movement.y = setMove.y
		if !animator.is_playing():
			animator.play("SPRING")
		Global.play_sound(springSound)


func _on_lid_area_body_entered(body):
	players.append(body)

func _on_lid_area_body_exited(body):
	players.erase(body)
