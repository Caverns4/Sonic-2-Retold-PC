@tool
extends Node2D

@export var length: int = 12
@export var smoothDrop: bool = true #Turn to false to match sonic 1 bridges
@export var texture: Texture2D = preload("res://Graphics/Gimmicks/bridge_log.png")
@export var texture2: Texture2D = preload("res://Graphics/Gimmicks/bridge_log.png")
@export var texture3: Texture2D = preload("res://Graphics/Gimmicks/bridge_log.png")

var frameCount: int = 0 #Count up
var frameDiff: Array[int] = [0,0,0,0,0,1,1,1,1,1]

var dropIndex: float = 1
var maxDepression: float = 0

var player: Array[CharacterBody2D] = []
var bridges: Array = []
var buffer: float = 0

func _ready() -> void:
	if !Engine.is_editor_hint():
		# texture overwrite
		if (texture != null):
			$log.texture = texture
		$log.rotation -= rotation
		
		# Set mask positions
		$Bridge/mask.position += Vector2.RIGHT*length*8
		$Bridge/mask.scale.x = (length)
		$PlayerCheck/mask.position += Vector2.RIGHT*length*8
		$PlayerCheck/mask.scale.x = (length)
		
		# duplicate log sprites until it matches the length
		for _i in range(length-1):
			var newLog: Sprite2D = $log.duplicate()
			add_child(newLog)
			bridges.append(newLog)
			$log.position.x += 16
		bridges.append($log)
	else:
		if (texture != null):
			$log.texture = texture

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if (texture != null):
			$log.texture = texture
		queue_redraw()
	frameCount=wrapi(frameCount+1,0,frameDiff.size()*4)

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		
		var playerTouch: bool = false
		
		for i in player:
			if i.movement.y >= 0:
				playerTouch = true
		
		if (playerTouch):
			# set buffer for colissions
			buffer = 1
			var averagePlayerOffset: float = 0
			for i in player:
				if i.movement.y >= 0:
					# check if average offset is set, if not then assign it to the first player
					if averagePlayerOffset == 0:
						averagePlayerOffset = i.global_position.x
					# get closest to center
					elif abs(averagePlayerOffset-(global_position.x+(length/2.0*16.0))) > abs(i.global_position.x-(global_position.x+(length/2.0*16.0))):
						averagePlayerOffset = lerp(averagePlayerOffset,i.global_position.x,0.5)
			# remove floor() if you are not making a pixel perfect game
			$Bridge.position.y = max(floor(length/2.0)*2.0-snapped(abs(global_position.x+(length*8.0)-averagePlayerOffset)/8.0,2-int(smoothDrop)),0)

			dropIndex = max(1,floor((averagePlayerOffset-global_position.x)/16.0)+1)
			if (dropIndex <= length/2.0):
				maxDepression = dropIndex*2 #Working from the left
			else:
				maxDepression = ((length-dropIndex)+1)*2 #Working from the right
		# check buffer (gives 1 frame to check for collisions, crouching usually breaks this)
		elif buffer > 0:
			buffer -= 1
		else:
			# Reset if no player found
			$Bridge.position.y = 0
			dropIndex = 1
			maxDepression = 0
		
		$PlayerCheck.scale.y = (maxDepression/8)+1
			
		# Loop through all segments to find their y position
		for i in range(bridges.size()):
			# Get difference in position of this log to current log
			var difference: int = abs((i+1)-dropIndex)
			
			# Get distance from current log to the closest side
			var logDistance: float = 0
			if (i < dropIndex):
				logDistance = 1-(difference/dropIndex) # Working from the left
			else:
				logDistance = 1-(difference/((length-dropIndex)+1)) # Working from the right
			
			# remove floor() if you are not making a pixel perfect game
			bridges[i].position.y = lerp(bridges[i].position.y,floor(maxDepression * sin(90 * deg_to_rad(logDistance))),delta*10)
			if texture2 != null:
				animateBridgeLog(bridges[i],logDistance)

func animateBridgeLog(bridgeLog: Sprite2D,logDist: float) -> void:
	var texArray: Array[Texture2D] = [texture,texture,texture2,texture3]
	var curFrame: float = logDist * (texArray.size()-1)
	curFrame = max(0,round(curFrame-(frameDiff[frameCount/4.0])))
	
	if maxDepression > 0 and buffer:
		bridgeLog.texture = texArray[curFrame]
	else:
		bridgeLog.texture = texArray[0]

# add players to array when entering or exiting area
func _on_PlayerCheck_body_entered(body: CharacterBody2D) -> void:
	player.append(body)

func _on_PlayerCheck_body_exited(body: CharacterBody2D) -> void:
	if (player.has(body)):
		player.erase(body)

# draw logs
func _draw() -> void:
	if Engine.is_editor_hint():
		for i in length:
			if i > 0:
				draw_texture(
					$log.texture,
					Vector2(($log.texture.get_width()*i)-$log.texture.get_width()/2,
					-$log.texture.get_height()/2)
					)
