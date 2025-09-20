@tool
extends Node2D

## The initial chain length.
@export var length: int = 32
## The distance in pixels for the hanger to travel when the players grab it.
@export var distance: int = 8
## The Node to be afftected when the player grabs the switch.
@export var targetNode: Node2D = null

var currentLength: float = 0

func _ready() -> void:
	currentLength = length

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		var touching = 0
		for i in $Hanger.players:
			var node: Player2D = i 
			if node.poleGrabID == $Hanger:
				touching += 1
		if touching > 0:
			currentLength = move_toward(currentLength,distance+abs(length),delta*128)
			if targetNode and targetNode.has_method("Trigger") and !targetNode.trigger:
				targetNode.Trigger()
		else:
			currentLength = move_toward(currentLength,abs(length),delta*128)
	else:
		currentLength = length
	updateChainLength()


func updateChainLength():
	$TextureRect.size.y = abs(currentLength)
	$Sprite2D.position.y = abs(currentLength)
	$Hanger.position.y = $Sprite2D.position.y + 24
