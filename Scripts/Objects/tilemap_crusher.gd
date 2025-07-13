extends Node2D

## Size of the sensor for player touching
@export var x_area_size: int = 32
## Size of the sensor for player touching
@export var y_area_size: int = 160
## Total distance for the object to move up and down.
@export var move_distance: int = 80
## Speed to raise
@export var lift_speed: int = 60
## Speed To Drop
@export var drop_speed: int = 480
## Time delay between rise/stomp
@export var time_delay: float = 0.0 
## Sound Effect to play when stomping
@export var soundStomp: AudioStream
## Sound Effect to play when destroyd
@export var collapse_sound: AudioStream

# platform particle
var PlatPart = preload("res://Entities/Misc/falling_block_plat.tscn")

var tiles: TileMapLayer = null
var offset: float = 0.0
var timer: float = 0.0
var direction: int = -1
var awaiting: bool = false

var intact: bool = true

# tile list array, contains an array inside set up like this
# [time left, cell coordinant]
var getTiles = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Get the child tilemap.
	for i in get_children():
		if i is TileMapLayer:
			tiles = i
			break
	timer = time_delay
	
	# grab from first layer
	for i in tiles.get_used_cells():
		# calculate by distance and give co-ordinant
		getTiles.append([i.length()/16,i])
	$Area2D/CollisionShape2D.shape.size = Vector2(x_area_size,abs(y_area_size))
	$VisibleOnScreenEnabler2D.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tiles:
		if intact:
			StomperMove(delta)
		else:
			DestroyTiles(delta)
	else:
		queue_free()

func StomperMove(delta: float):
	timer-=delta
	if timer <= 0.0 and awaiting:
		awaiting = false
		if tiles.position.y == 0.0:
			SoundDriver.play_sound2(soundStomp)
	
	if !awaiting:
		var speed = abs(drop_speed)
		if direction < 0:
			speed = abs(lift_speed)
			offset = move_toward(offset,0-move_distance,speed*delta)
		else:
			offset = move_toward(offset,0,speed*delta)
		tiles.position.y = offset
		$Area2D.position.y = offset
		
		var targetOff = clamp(abs(move_distance)*direction,0-abs(move_distance),0)
		
		if direction != 0 and offset == targetOff:
			direction = 0-direction
			awaiting = true
			timer = time_delay
	else:
		queue_free()

func DestroyTiles(delta):
		# loop through and generate a tile particle
		for i in getTiles.size():
			# check that i is still below the tile size
			if i < getTiles.size():
				# decrease timer if above 0
				if getTiles[i][0] > 0:
					getTiles[i][0] -= delta
				# remove timer (and array point) and create the block particle
				else:
					# create particle (we pull from the tilemap)
					var platPart = PlatPart.instantiate()
					add_child(platPart)
					# set position
					platPart.position += Vector2(getTiles[i][1]*tiles.tile_set.tile_size)+tiles.position
					# references for thet ile
					var tileData = tiles.get_cell_tile_data(getTiles[i][1])
					var tileSource = tiles.get_cell_source_id(getTiles[i][1])
					# grab any materials
					platPart.material = tileData.material
					# check if the tile's been flipped
					platPart.flip_h = tileData.flip_h
					platPart.flip_v = tileData.flip_v
					# check for colour changes
					platPart.modulate = tileData.modulate
					
					# grab the image and the position and size
					var tileSetSource = tiles.tile_set.get_source(tileSource)
					if tileSetSource is TileSetAtlasSource:
						platPart.texture = tileSetSource.texture
						platPart.region_rect.position = Vector2(tiles.get_cell_atlas_coords(getTiles[i][1]))*Vector2(tileSetSource.texture_region_size)
						platPart.region_rect.size = Vector2(tileSetSource.texture_region_size)
					
					# erase from tilemap
					tiles.set_cell(getTiles[i][1])
					getTiles.remove_at(i)
					# decrease i so we don't skip any tiles
					i -= 1
					#Wait 8 seconds before deletion
					await get_tree().create_timer(4.0).timeout
					queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.isSuper and intact:
		intact = false
		tiles.collision_enabled = false
		Global.play_sound(collapse_sound)
