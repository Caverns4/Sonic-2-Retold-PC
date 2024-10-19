extends Node2D

#Similar to the normal swing, however this can have multiple platforms,
#And does not slow down, just ratates in a circle

# Export Variables
@export_range (1,4) var platformCount:int = 3
@export var chains:int = 4 # How many chains will be rendered # (int,0,100)
@export var speed = 1.0
@export var plat_img:Texture2D # Texture2D for the platform
@export var chain_img:Texture2D # Texture2D for the chains
# Declare time, previous position, editor time, and grab the platform's node
var time = 0
var edittime = 0 # Time for the editor version
@onready var platform = $SwingPlatform # Grab the platform's node.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	platform.show()
	platform.get_node("Sprite2D").texture = plat_img
	# Change platform shape
	platform.get_node("Shape3D").shape.size.x = plat_img.get_size().x
	var nextChild = null
	for i in platformCount-1:
		nextChild = platform.duplicate()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Editor display only
	pass

func _physics_process(delta: float) -> void:
	#ingame
	pass
