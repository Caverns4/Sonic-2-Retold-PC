@tool
extends Node2D

var Platform = preload("res://Entities/Obstacles/InvisiblePlatform.tscn")

var playerPlatforms = [] #one node per player
var weightVals = [] # How long each player's been standing on their respective platform.
var restPos = 0 #Position the invisible platforms move up to.

func _ready():
	if !Engine.is_editor_hint():
		if (get_tree().current_scene is MainGameScene): # and !Global.levelSelectFlag:
			visible = false
		var size = Vector2(32*scale.x,32*scale.y)
		restPos = global_position.y #- (size.y/2)
		
		#On init, setup an array for every player.
		for i in Global.players.size()+1:
			var node = Platform.instantiate()
			add_child(node)
			playerPlatforms.append(node)
			weightVals.insert(weightVals.size(),0.0)
			node.top_level = true
		

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
		for i in playerPlatforms.size():
			var plat = playerPlatforms[i]
			plat.global_position.y = restPos + weightVals[i]
			plat.global_position.x = Global.players[i].global_position.x
			
			if plat.get_collision_layer_value(1):
				weightVals[i] += (delta*16)
			else:
				weightVals[i] = 0.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.players.has(body):
		var index = Global.players.find(body)
		playerPlatforms[index].set_collision_layer_value(1,true)
	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if Global.players.has(body):
		var index = Global.players.find(body)
		playerPlatforms[index].set_collision_layer_value(1,false)
