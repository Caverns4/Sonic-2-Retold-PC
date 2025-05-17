extends Node2D

# Todo: Behavior
#if a player enters the area range, wait for the player to "land" at the
#bottom before starting to spin the player up and own in their corkscrew
#animation.

# length of the corkscrew
@export var length = 1

# player tracking arrays
var playerList = []
var playerTimers = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.players.has(body):
		playerList.append(body)
		var node = Global.players[Global.players.find(body)]
		if body.ground:
			node.allowTranslate = true
			node.set_state(body.STATES.CORKSCREW)
		node.controlObject = self


func _on_area_2d_body_exited(body: Node2D) -> void:
	if Global.players.has(body) and body.controlObject == self:
		var node = Global.players[Global.players.find(body)]
		node.allowTranslate = false
	playerList.erase(body)
