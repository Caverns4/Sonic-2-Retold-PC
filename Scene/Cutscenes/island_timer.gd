extends Timer

@export var background_layer: ParallaxBackground

func _on_timeout() -> void:
	if background_layer.has_method("set_island_state"):
		background_layer.set_island_state(false)
