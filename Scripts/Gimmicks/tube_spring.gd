extends StaticBody2D

@export_enum("Weak", "Strong") var power: int = 0 # The power of the spring when hopped on
@export var springSound: AudioStream = preload("res://Audio/SFX/Gimmicks/s2br_Spring.wav")

@onready var animator: AnimationPlayer = $AnimationPlayer

var speed: Array[float] = [10.5,16]

enum STATES{CLOSED,OPEN,CLOSING}
var state: STATES = STATES.CLOSED

var players: Array[Player2D] = [] #Detected players in the Area2D

func _process(_delta: float) -> void:
	match state:
		STATES.CLOSED:
			if players.size() > 0:
				state = STATES.OPEN
				animator.play("OPEN")
		STATES.OPEN:
			if players.size() == 0:
				state = STATES.CLOSED
				animator.play("CLOSE")


func physics_collision(body: CharacterBody2D, hitVector: Vector2) -> void:
	if hitVector == Vector2.DOWN:
		var setMove: Vector2 =  Vector2.UP.round()*speed[power]*60
		# disable ground
		body.ground = false
		body.set_state(body.STATES.AIR)
		body.air_control = true
		#Setup Player animation
		var curAnim: String = "walk"
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
		SoundDriver.play_sound(springSound)


func _on_lid_area_body_entered(body: CharacterBody2D) -> void:
	players.append(body)

func _on_lid_area_body_exited(body: CharacterBody2D) -> void:
	players.erase(body)
