extends Control

@onready var viewport1 = $CanvasLayer/SubViewportContainer/SubViewport
@onready var viewport2 = $CanvasLayer/SubViewportContainer2/SubViewport

@onready var cameraPlayer1 = $CanvasLayer/SubViewportContainer/SubViewport/CameraP1
@onready var cameraPlayer2 = $CanvasLayer/SubViewportContainer2/SubViewport/CameraP2


# Parallax Layers
var parallaxBackgrounds = [
	"res://Scene/Backgrounds/00-EmeraldHill.tscn",
	"res://Scene/Backgrounds/01-HiddenPalace.tscn",
	"res://Scene/Backgrounds/02-HillTop.tscn",
	"res://Scene/Backgrounds/03-ChemicalPlant.tscn"
]

# Player memory
var playersReady = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var parallax = parallaxBackgrounds[min(Global.savedZoneID,parallaxBackgrounds.size()-1)]
	var scene = load(parallax)
	var instance = scene.instantiate()
	$CanvasLayer/SubViewportContainer/SubViewport.add_child(instance)
	instance = scene.instantiate()
	$CanvasLayer/SubViewportContainer2/SubViewport.add_child(instance)
	
	QueueUpPlayers()
	viewport1.world_2d = get_viewport().world_2d
	viewport2.world_2d = get_viewport().world_2d
	
	var resolution = Global.aspectResolutions[Global.aspectRatio]
	$CanvasLayer/SubViewportContainer.size.x = resolution.x
	$CanvasLayer/SubViewportContainer2.size.x = resolution.x
	$CanvasLayer/SubViewportContainer/SubViewport.size = Vector2i(resolution.x,112)
	$CanvasLayer/SubViewportContainer2/SubViewport.size = Vector2i(resolution.x,112)
	$CanvasLayer/SubViewportContainer/SubViewport.size_2d_override =  Vector2i(resolution.x,224)
	$CanvasLayer/SubViewportContainer2/SubViewport.size_2d_override =  Vector2i(resolution.x,224)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if playersReady == false:
		QueueUpPlayers()
	elif playersReady == true and !Global.players:
		queue_free()
	else:
		cameraPlayer1.global_position = Global.players[0].camera.global_position
		cameraPlayer1.limit_left = Global.players[0].camera.limit_left
		cameraPlayer1.limit_bottom = Global.players[0].camera.limit_bottom
		cameraPlayer1.limit_right = Global.players[0].camera.limit_right
		cameraPlayer2.global_position = Global.players[1].camera.global_position
		cameraPlayer2.limit_left = Global.players[1].camera.limit_left
		cameraPlayer2.limit_bottom = Global.players[1].camera.limit_bottom
		cameraPlayer2.limit_right = Global.players[1].camera.limit_right

func QueueUpPlayers():
	if Global.players.size() and Global.players.size() > 1:
		playersReady = true
