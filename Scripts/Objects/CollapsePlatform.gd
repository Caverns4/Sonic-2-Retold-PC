extends Area2D

# collapsing platform code by sharb

# platform particle
var PlatPart = preload("res://Entities/Misc/falling_block_plat.tscn")

# tilemap source to pull from
@export_node_path("TileMapLayer") var tile
# how fast the platform collapses
@export var speed = 3.0
# how long to wait before playing the sound
@export var soundDelay = 0.5

# player array
var players = []

# used for detecting if the platform is collapsing
var active = false

# the collapsing sound
@export var collapse_sound = preload("res://Audio/SFX/Gimmicks/s2br_Collapse.wav")
@export var respawn = true #If the object should respawn on a timer.
var respawnCoords = position

# tile list array, contains an array inside set up like this
# [time left, cell coordinant]
var getTiles = []

func _ready():
	# set the tile reference to the tilemap
	tile = get_node(tile)
	# grab from first layer
	
	# Figure out the maximum distance away
	var maxDist = Vector2.ZERO
	for distance in tile.get_used_cells():
		if distance.length() > maxDist.length():
			maxDist = distance
	
	for distance in tile.get_used_cells():
		# calculate by distance and give co-ordinant
		getTiles.append([(maxDist.length() - distance.length())
		/speed,distance])
		

func _physics_process(delta):
	# check if to activate
	if !active:
		# if we can detect any players and they're on the flor, activate
		for i in players:
			# do a active check to prevent the sound playing twice
			if i.ground and !active:
				active = true
				# wait for sound delay
				#await get_tree().create_timer(soundDelay,false).timeout
				# play sound globally (prevents sound overlap, aka loud sounds)
				SoundDriver.play_sound(collapse_sound)
	else:
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
					platPart.position += Vector2(getTiles[i][1]*tile.tile_set.tile_size)+tile.position
					# references for thet ile
					var tileData = tile.get_cell_tile_data(getTiles[i][1])
					var tileSource = tile.get_cell_source_id(getTiles[i][1])
					# grab any materials
					platPart.material = tileData.material
					# check if the tile's been flipped
					platPart.flip_h = tileData.flip_h
					platPart.flip_v = tileData.flip_v
					# check for colour changes
					platPart.modulate = tileData.modulate
					
					# grab the image and the position and size
					var tileSetSource = tile.tile_set.get_source(tileSource)
					if tileSetSource is TileSetAtlasSource:
						platPart.texture = tileSetSource.texture
						platPart.region_rect.position = Vector2(tile.get_cell_atlas_coords(getTiles[i][1]))*Vector2(tileSetSource.texture_region_size)
						platPart.region_rect.size = Vector2(tileSetSource.texture_region_size)
					
					# erase from tilemap
					tile.set_cell(getTiles[i][1])
					getTiles.remove_at(i)
					# decrease i so we don't skip any tiles
					i -= 1
					#Wait 8 seconds before deletion
					await get_tree().create_timer(4.0).timeout
					queue_free()

# check for players
func _on_body_entered(body):
	if !players.has(body):
		players.append(body)

func _on_body_exited(body):
	if players.has(body):
		players.erase(body)
