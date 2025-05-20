@tool
extends Node2D

#Similar to the normal swing, however this can have multiple platforms,
#And does not slow down, just ratates in a circle

# Export Variables
@export_range (1,16) var hazard_count:int = 3
@export var chains:int = 4 # How many chains will be rendered # (int,0,100)
@export var speed = 1.0
@export var hazard_img:Texture2D # Texture2D for the platform
@export var chain_img:Texture2D # Texture2D for the chains
@export var hazard_radius: int = 16
# Declare time, previous position, editor time, and grab the platform's node
var edittime = 0 # Time for the editor version
@onready var platform = $SwingPlatform # Grab the platform's node.

var platforms = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(!Engine.is_editor_hint()): # If not in editor, show the platform, and set the platform's image
		platform.show()
		platform.get_node("Sprite2D").texture = hazard_img
		#Change root node tex
		$SwingPole.texture = chain_img
		# Change platform shape
		platform.get_node("CollisionShape2D").shape.radius = hazard_radius
		platforms.append(platform)
		var nextChild = null
		for i in hazard_count-1:
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

func _physics_process(_delta: float) -> void:
	if(!Engine.is_editor_hint()): # In-Game
		# Calcutlate direction
		var yOffset = chains * 16 + (float(16) / 2.0)
		var direction = Vector2.DOWN
		var xOffset = 0.0
		for i in platforms.size():
			direction = Vector2.DOWN.rotated((deg_to_rad(fmod(xOffset + Global.globalTimer * 60 * speed,360))))
			xOffset += (360.0/hazard_count)
			platforms[i].position = (direction * yOffset).round()

func _draw():
	if(!Engine.is_editor_hint()):  # Non-editor stuff
		#for i # of platforms, in j # of chains
		for i in hazard_count:
			var direction = platforms[i].position.normalized()
			for j in chains:
				var chainPos = direction * ((j + 1) * 16)
				chainPos -= Vector2(float(chain_img.get_width()) / 2,float(chain_img.get_height()) / 2)
				draw_texture(chain_img,chainPos,Color(1,1,1,1))
		#End non-editor code loop
		return
	
	# Draw moving platforms
	var diff = 0
	var temppos = Vector2.DOWN
	var distance = chains * 16 + (float(16) / 2.0)
	for i in hazard_count:
		temppos = Vector2(0,distance).rotated((deg_to_rad(fmod(diff + edittime * 60 * speed,360))))
		diff += (360.0/hazard_count)
		temppos -= Vector2(float(hazard_img.get_width()) / 2,float(hazard_img.get_height()) / 2)
		draw_texture(hazard_img,temppos,Color(1,1,1,1))
	
	
