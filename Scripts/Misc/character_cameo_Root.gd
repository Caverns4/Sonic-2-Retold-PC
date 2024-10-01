extends Node2D

const WAIT_TIME = 3.0

@export_enum("Ring","Speed Shoes","Invincibility",
"Shield","Elec Shield","Fire Shield",
"Bubble Shield","Super","Teleport",
"Boost","Eggman","?",
"Extra Life","Tails Life") var present = 0

var Projectile = preload("res://Entities/Items/Monitor.tscn")
var drppedItem = null

@export var character = Texture2D

#Object state controllers
enum STATES{IDLE,THROW,JUMP}
var state = 0
var stateTimer = 0.0
var direction = -1

var players = [] # targets in the sensor area

@onready var sprite = $CharacterBody2D/CharacterSprite

func _ready() -> void:
	pass
