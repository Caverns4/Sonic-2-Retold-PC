extends Node2D


var players = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.players.has(body):
		players.append(body)
		var node = Global.players[Global.players.find(body)]
		node.translate = true
		node.controlObject = self
		node.set_state(body.STATES.CORKSCREW)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if Global.players.has(body) and body.controlObject == self:
		var node = Global.players[Global.players.find(body)]
		node.translate = false
	players.erase(body)
