extends Control

@onready var viewport1 = $CanvasLayer/SubViewportContainer/SubViewport
@onready var viewport2 = $CanvasLayer/SubViewportContainer2/SubViewport

@onready var cameraPlayer1 = $CanvasLayer/SubViewportContainer/SubViewport/CameraP1
@onready var cameraPlayer2 = $CanvasLayer/SubViewportContainer2/SubViewport/CameraP2


# Player memory
var players = []
var playersReady = false

# Called when the node enters the scene tree for the first time.
func _ready():
	QueueUpPlayers()
	viewport1.world_2d = get_viewport().world_2d
	viewport2.world_2d = get_viewport().world_2d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if playersReady == false:
		QueueUpPlayers()
	else:
		cameraPlayer1.global_position = players[0].camera.global_position
		cameraPlayer1.limit_bottom = players[0].camera.limit_bottom
		cameraPlayer1.limit_right = players[0].camera.limit_right
		cameraPlayer2.global_position = players[1].camera.global_position
		cameraPlayer2.limit_bottom = players[1].camera.limit_bottom
		cameraPlayer2.limit_right = players[1].camera.limit_right

func QueueUpPlayers():
	players = get_tree().get_nodes_in_group("Player")
	if players.size() and players.size() > 1:
		playersReady = true
