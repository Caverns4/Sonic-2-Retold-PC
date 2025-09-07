@tool
extends Node2D

@export var sinkingSpeed = 16

var Platform = preload("res://Entities/Obstacles/InvisiblePlatform.tscn")
var playerPlatforms = [] #one node per player
var weightVals = [] # How long each player's been standing on their respective platform.
var restPos = 0 #Position the invisible platforms move up to.

func _ready():
	if !Engine.is_editor_hint():
		if (get_tree().current_scene is MainGameScene): # and !Global.levelSelectFlag:
			visible = false
		var size = Vector2(32*scale.x,32*scale.y)
		restPos = global_position.y - 8

func _physics_process(delta: float) -> void:
	var size = Vector2(32*scale.x,32*scale.y) 
	$TopLeft.global_position.x = global_position.x - (size.x/2)
	$TopLeft.global_position.y = global_position.y - (size.y/2)
	$TopRight.global_position.x = global_position.x + ((size.x/2)-16)
	$TopRight.global_position.y = global_position.y - (size.y/2)
	$BottomLeft.global_position.x = global_position.x - (size.x/2)
	$BottomLeft.global_position.y = global_position.y + ((size.y/2)-16)
	$BottomRight.global_position.x = global_position.x + ((size.x/2)-16)
	$BottomRight.global_position.y = global_position.y + ((size.y/2)-16)
	
	if !Engine.is_editor_hint():
		if Global.players.size() > playerPlatforms.size():
			dynamically_append_platforms()
		
		for i in playerPlatforms.size():
			var plat = playerPlatforms[i]
			var player = Global.players[i]
			plat.global_position.y = restPos + weightVals[i]
			plat.global_position.x = player.global_position.x
			
			plat.global_position.x = clamp(
			plat.global_position.x,
			global_position.x - (size.x/2),
			global_position.x + ((size.x/2)-16))

			if plat.active:
				weightVals[i] += (delta*sinkingSpeed)
				if weightVals[i] > 32:
					weightVals[i] = 256
			else:
				weightVals[i] = max(0,weightVals[i]-(delta*sinkingSpeed*8))

func dynamically_append_platforms():
		for i in Global.players.size():
			if i >= playerPlatforms.size():
				var node = Platform.instantiate()
				add_child(node)
				playerPlatforms.append(node)
				weightVals.insert(weightVals.size(),0.0)
				node.top_level = true
				node.whichChar = Global.players[i]


func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.players.has(body):
		var index = Global.players.find(body)
		playerPlatforms[index].set_collision_layer_value(1,true)
	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if Global.players.has(body):
		var index = Global.players.find(body)
		playerPlatforms[index].set_collision_layer_value(1,false)
