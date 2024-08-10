extends Control

@onready var viewport1 = $CanvasLayer/SubViewportContainer/SubViewport
@onready var viewport2 = $CanvasLayer/SubViewportContainer2/SubViewport

@onready var cameraPlayer1 = $CanvasLayer/SubViewportContainer/SubViewport/CameraP1
@onready var cameraPlayer2 = $CanvasLayer/SubViewportContainer2/SubViewport/CameraP2


# Player memory
var players = []
var player1 = null
var player2 = null
var playersReady = false

# Called when the node enters the scene tree for the first time.
func _ready():
	QueueUpPlayers()
	viewport1.world_2d = get_viewport().world_2d
	viewport2.world_2d = get_viewport().world_2d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if playersReady == false:
		QueueUpPlayers()
	else:
		
		#for i in player1.get_children():
		#	if i is Camera2D:
		#		cameraPlayer1.position = i.global_position
		#for i in player2.get_children():
		#	if i is Camera2D:
		#		cameraPlayer2.position = i.global_position
		cameraPlayer1.global_position = floor(player1.global_position)
		cameraPlayer2.global_position = floor(player2.global_position)
		pass

func QueueUpPlayers():
	players = get_tree().get_nodes_in_group("Player")
	if players.size() and players.size() > 1:
		player1 = players[0]
		player2 = players[1]
		playersReady = true
