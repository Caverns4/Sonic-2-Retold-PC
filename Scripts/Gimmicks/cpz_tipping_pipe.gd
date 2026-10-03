extends AnimatableBody2D

@export var duration: float = 2.1333
@export var delay: float = 0.0

enum STATES{DELAY,DROP}
var state: STATES = STATES.DELAY

var stateTimer: float = 1.0

@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	stateTimer = float(duration + (delay/60.0))

func _process(delta: float) -> void:
	match state:
		STATES.DELAY:
			stateTimer -= delta
			if stateTimer <= 0.0:
				state = STATES.DROP
				animator.play("FLIP")
				stateTimer = 0.0
		STATES.DROP:
			if !animator.is_playing():
				state = STATES.DELAY
				animator.play("RESET")
				stateTimer = duration
