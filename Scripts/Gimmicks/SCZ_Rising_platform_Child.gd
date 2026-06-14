extends AnimatableBody2D

@onready var animator: AnimationPlayer = $AnimationPlayer

signal animation_over

func _ready() -> void:
	animator.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	animation_over.emit(self,anim_name)
