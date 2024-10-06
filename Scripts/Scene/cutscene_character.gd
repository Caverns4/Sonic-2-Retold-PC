@tool
extends Node2D

@export_enum("RESET","walk","run","peelout",
"roll","crouch","spinDash","lookUp","idle","idle2") var animation = "RESET"

@onready var animator = $PlayerAnimation

var prevAnim = "idle"

func _ready():
	pass

func _process(delta):
	if animation != prevAnim:
		animator.play(animation)
		prevAnim = animation
