@tool
extends Node2D

@export_enum("RESET","walk","run","peelout",
"roll","crouch","spinDash","lookUp","idle","idle2") var animation: String = "RESET"

@onready var animator: AnimationPlayer = $PlayerAnimation

var prevAnim: StringName = "idle"

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if animation != prevAnim:
		animator.play(animation)
		prevAnim = animation
