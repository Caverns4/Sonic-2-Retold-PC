@tool
extends Node2D

## The initial chain length.
@export var length: int = 32
## The distance in pixels for the hanger to travel when the players grab it.
@export var distance: int = 8

## The Node to be afftected when the player grabs the switch.
@export var targetNode: Node2D = null

@export_group("Appearance")
@export var vine_texture: Texture2D = preload("res://Graphics/Gimmicks/DHZ_VineLength.png")
@export var hook_texture: Texture2D = preload("res://Graphics/Gimmicks/DHZ_VineHook.png")

var currentLength: float = 0

func _ready() -> void:
	currentLength = length
	$VineSprite.texture = vine_texture
	$HookSprite.texture = hook_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		var touching: int = 0
		for i: Player2D in $Hanger.players:
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
		$VineSprite.texture = vine_texture
		$HookSprite.texture = hook_texture
	updateChainLength()


func updateChainLength() -> void:
	$VineSprite.size.y = abs(currentLength)
	$HookSprite.position.y = abs(currentLength)
	$Hanger.position.y = $HookSprite.position.y + 24
