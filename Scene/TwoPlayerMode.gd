extends Node2D

@onready var screen1 = $GridContainer/SubViewportContainer1/SubViewport
@onready var screen2 = $GridContainer/SubViewportContainer2/SubViewport

@onready var camera1 = $GridContainer/SubViewportContainer1/SubViewport/Sprite2D
@onready var camera2 = $GridContainer/SubViewportContainer2/SubViewport/Sprite2D

var players = []
var player1 = null
var player2 = null

var playersReady = false

func _ready():
	QueueUpPlayers()
	camera1.scale.y = 1.0
	#camera1.texture = screen1.get_texture() # Just get the texture directly.




func _process(_delta):
	if playersReady == false:
		QueueUpPlayers()
	else:
		for i in player1.get_children():
			if i is Camera2D:
				var img = i.get_viewport().get_texture().get_data()
				var tex = ImageTexture.new()
				tex.create_from_image(img)
				camera1.texture = img
				
		#camera1.global_position = player1.global_position
		#camera2.global_position = player2.global_position
		$GridContainer/SubViewportContainer2/SubViewport/Camera2D.global_position = player2.global_position
		pass

func QueueUpPlayers():
	players = get_tree().get_nodes_in_group("Player")
	if players.size() and players.size() > 1:
		player1 = players[0]
		player2 = players[1]
		#print(player1)
		#print(player2)
		playersReady = true
