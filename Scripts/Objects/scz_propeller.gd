extends "res://Scripts/Objects/Hazard.gd"

@export var damage: bool = true
@export var play_sound: bool = true

func _ready() -> void:
	monitoring = damage
	if play_sound:
		$HeliSFX.play()
	#$HeliSFX.autoplay = play_sound
