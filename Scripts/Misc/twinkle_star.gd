extends Node2D

var queue = false

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if queue and !$AnimatedSprite2D.is_playing() and !$AudioStreamPlayer.playing:
		queue_free()
	
	if visible and !queue:
		queue = true
		$AudioStreamPlayer.play()
		$AnimatedSprite2D.play("Twinkle")
