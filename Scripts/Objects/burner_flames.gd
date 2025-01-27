extends "res://Scripts/Objects/Hazard.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)

func activate():
	$AnimatedSprite2D.play("Pop")

func deactivate():
	$AnimatedSprite2D.play("default")
	$CollisionShape2D.disabled = true

func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.play("Burn")
	$CollisionShape2D.disabled = false
