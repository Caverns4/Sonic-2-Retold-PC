extends Node2D

## The Node to be afftected when the player grabs the switch.
@export var targetNode: Node2D = null

var currentLength: float = 0

func _ready() -> void:
	currentLength = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var touching = 0
	for i in $Hanger.players:
		var node = i[0]
		if i[1]:
			touching += 1
	if touching > 0:
		currentLength = move_toward(currentLength,8,delta*128)
		if targetNode and targetNode.has_method("Trigger") and !targetNode.trigger:
			targetNode.Trigger()
	else:
		currentLength = move_toward(currentLength,0,delta*128)
	updateChainLength()


func updateChainLength():
	$Sprite2D.position.y = abs(currentLength)
	$Hanger.position.y = abs(currentLength)+60
