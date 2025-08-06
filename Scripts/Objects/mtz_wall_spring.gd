extends Area2D

@export_enum("Left","Right") var spring_direction: int = 0
@export var spring_power = 8
@export var spring_sfx = preload("res://Audio/SFX/Gimmicks/s2br_Spring.wav")

func _ready() -> void:
	spring_direction = spring_direction*2-1


func _on_body_entered(body: Player2D) -> void:
	if !body.controlObject:
		body.set_state(body.STATES.AIR)
		body.angle = 0
		body.allowTranslate = false
		body.airControl = true
		body.movement.y = 0-(60*spring_power)
		body.movement.x = 60*(spring_power*spring_direction)
		var curAnim = "walk"
		body.animator.play("corkScrew")
		body.animator.queue(curAnim)
	if $VisibleOnScreenNotifier2D.is_on_screen():
		SoundDriver.play_sound(spring_sfx)
