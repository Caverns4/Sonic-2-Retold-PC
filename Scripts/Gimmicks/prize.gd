extends CharacterBody2D

@export var value = 1
@export var sfx: AudioStream

var target: Player2D = null

func _physics_process(delta: float) -> void:
	if !target:
		queue_free()
	
	global_position = global_position.move_toward(target.global_position,360*delta)
	if global_position == target.global_position:
		SoundDriver.play_sound2(sfx)
		target.rings = clampi(target.rings+value,0,999)
		queue_free()
