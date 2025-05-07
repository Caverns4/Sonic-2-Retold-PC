extends Node2D

#Move # of Blocks in 

@export_range (1,4) var block_count:int = 3
## Texture2D for the block
@export var block_img:Texture2D
## Direction (and speed) the blocks spin at
@export var speed:float = 1.0

var radius:int = 32

@onready var platform = $Block # Grab the platform's node.
var platforms = []

var position_box = Vector2(1,1)

var editTimer = 0.0 # To be used for editor preview
var moveTimer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(!Engine.is_editor_hint()): # If not in editor, show the platform, and set the platform's image
		platform.show()
		platform.get_node("Sprite2D").texture = block_img
		radius = block_img.get_width()/2
		#Change root node tex
		platform.get_node("CollisionShape2D").shape.size = block_img.get_size()
		platforms.append(platform)
		var nextChild = null
		for i in block_count-1:
			nextChild = platform.duplicate()
			add_child(nextChild)
			platforms.append(nextChild)
	else: # Hide platform from editor
		platform.hide() # The platform is drawn in this script instead for the editor.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Editor display only
	if(Engine.is_editor_hint()): # All the editor code is in draw
		pass

func _physics_process(delta: float) -> void:
	if(!Engine.is_editor_hint()): # In-Game
		var direction = Vector2.DOWN
		var xOffset = 0.0
		for i in platforms:
			direction = Vector2.DOWN.rotated((deg_to_rad(fmod(xOffset + Global.globalTimer * speed * 60,360))))
			xOffset += (360.0/block_count)
			var pos = Vector2(direction*radius*2.2)
			pos.x = clampf(pos.x,-radius*2,radius*2)
			pos.y = clampf(pos.y,-radius,radius)
			i.position = pos
		
