extends Node2D

@onready var head = $RexonHead

var oscilationValue = 0 #Make the segments sway aback and forth

var childStates = []

func _process(delta: float) -> void:
	if !head and self.has_node("Neck1"):
		$Neck1.queue_free()
		$Neck2.queue_free()
		$Neck3.queue_free()
		$Neck4.queue_free()
