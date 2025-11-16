extends CharacterBody2D

@onready var pilot = $TurtloidPilot

func _ready() -> void:
	velocity.x = 30.0
	$VisibleOnScreenEnabler2D.show()

func _physics_process(delta: float) -> void:
	move_and_slide()
