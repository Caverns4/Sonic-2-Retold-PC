extends AnimatedSprite2D

# animation behaviours, if you want some specific behaviours you can program them with this
var behaviour: int = 0
enum TYPE {NORMAL, FOLLOW_WATER_SURFACE}

func _ready() -> void:
	if !is_playing():
		play("default")
	if behaviour == 0:
		set_process(false)

func _process(_delta: float) -> void:
	match(behaviour):
		TYPE.FOLLOW_WATER_SURFACE:
			if Global.waterLevel>0:
				global_position.y = Global.waterLevel-16

func _on_animation_finished() -> void:
	queue_free()
