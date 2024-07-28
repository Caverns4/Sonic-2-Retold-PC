extends Node2D


@export var level = preload("res://Scene/Zones/EmeraldHill1.tscn");

@onready var screen1 = $GridContainer/SubViewportContainer1/SubViewport
@onready var screen2 = $GridContainer/SubViewportContainer2/SubViewport

@onready var camera1 = $GridContainer/SubViewportContainer1/SubViewport/Camera2D
@onready var camera2 = $GridContainer/SubViewportContainer2/SubViewport/Camera2D

func _ready():
	Global.TwoPlayer = true
	
	var gameLevel = level.instantiate() as Node2D
	add_child(gameLevel)
	#gameLevel.reparent(screen1)
	
	screen1.world_2d = gameLevel
	#screen2.world_2d = screen1.world_2d
	
	#var player1 = gameLevel.find_child("Player")
	#if player1 != null:
	#	screen1.get_viewport().get_camera_2d()
	
	#player1.reparent(screen1)
	#var player2 = gameLevel.find_child("Player 2")
	#player2.reparent(screen2)

func _process(_delta):
	
	pass
