@tool
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
var edittime = 0 # Time for the editor version
@onready var platform = $SwingPlatform # Grab the platform's node.

var platforms = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(!Engine.is_editor_hint()): # If not in editor, show the platform, and set the platform's image
		platform.show()
		platform.get_node("Sprite2D").texture = plat_img
		# Change platform shape
		platform.get_node("Shape3D").shape.size.x = plat_img.get_size().x
		platforms.append(platform)
		var nextChild = null
		for i in platformCount-1:
			nextChild = platform.duplicate()
			add_child(nextChild)
			platforms.append(nextChild)
	else: # Hide platform from editor
		platform.hide() # The platform is drawn in this script instead for the editor.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Editor display only
	if(Engine.is_editor_hint()): # All the editor code is in draw
		edittime = fmod(edittime + (delta),360)
	# Update is used in editor, and for the chains on the swing.
	queue_redraw()

func _physics_process(delta: float) -> void:
	if(!Engine.is_editor_hint()): # In-Game
		# Calcutlate direction
		var distance = chains * 16 + (float(16) / 2.0)
		var direction = Vector2.DOWN
		var diff = 0.0
		for i in platforms.size():
			direction = Vector2.DOWN.rotated((deg_to_rad(fmod(diff + Global.globalTimer * 60 * speed,360))))
			diff += (360.0/platformCount)
			platforms[i].position = (direction * distance).round()

func _draw():
	if(!Engine.is_editor_hint()):  # Non-editor stuff
		#for i # of chainlinks, in j # of platforms
		
		return
	
	# Draw moving platforms
	var diff = 0
	var temppos = Vector2.DOWN
	var distance = chains * 16 + (float(16) / 2.0)
	for i in platformCount:
		temppos = Vector2(0,distance).rotated((deg_to_rad(fmod(diff + edittime * 60 * speed,360))))
		diff += (360.0/platformCount)
		temppos -= Vector2(float(plat_img.get_width()) / 2,float(plat_img.get_height()) / 2)
		draw_texture(plat_img,temppos,Color(1,1,1,1))
	
	
