extends Node2D

# Any player in PlayerOverlap gets pushed in the
# direction of this object's rotation with a minimum speed of Vectr2.UP * 6.
# This movement is done by modifying velocity, not translation.

#PlayerEntry is just a simple sensor to trigger the effect when the field is entered.

@onready var playerEntry = $PlayerEntry
@onready var playerCol = $PlayerOverlap

var players = [] # Nodes



func _on_player_entry_body_entered(body: Node2D) -> void:
	players.append(body)


func _on_player_entry_body_exited(body: Node2D) -> void:
	players.erase(body)


func _on_player_overlap_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_player_overlap_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
