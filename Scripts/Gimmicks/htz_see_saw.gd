extends StaticBody2D

@export_enum("left","right") var startDirection = 1
@export var springPower = 20

@export var counterWeight = true
@export var counterWeightSprite = preload("res://Graphics/Hazards/TEST.png")
# Image should be a horizonal sprite sheet with each frame being of equal width and height.
# It will cycle through frames at a consistent speed.

@onready var sprite = $Sprite2D
var springSound = preload("res://Audio/SFX/Gimmicks/Springs.wav")

const ROTATION_AMOUNT = 26.0 #The max rotation of the object.
const LOCK_TIME = 0.1 #Lock time after the See-Saw changes frame.

var child = null #Child Node if applicable.
var childCreated = false #Just in case so the child sprite won't get created twice.
var childFrame = 0.0
var childAnimationTimer = 0.1


var reactTime = 0 #Time for the See-Saw to stay idle
var balance =   0 # Current weight distribution
var balanceMemory = 0 #The last state of the platform
var weights = [] #Objects currently on the platform
var playerVelMemory = []

#DEPRICATED
var direction = 0 
var targetYPositions =[
	[-40,-36,-32,-28,-24,-20,-16,-12, -8,-4 ,  0], #Heavy on right
	[-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24], #Centered
	[  0, -4, -8,-12,-16,-20,-24,-28,-32,-36,-40]  #Heavy on Left
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if startDirection > 0:
		balance = 1
	else:
		balance = -1
	
	if counterWeight and !childCreated:
		child = $SolWeight
		var temp = child.global_position
		child.top_level = true
		child.global_position = temp
		childCreated = true
	elif !counterWeight:
		$SolWeight.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	balanceMemory = balance
	
	reactTime -= delta
	if reactTime > 0.0:
		return
	
	var objectWeights = [] #The weight of each object

	for i in weights.size():
		var node = weights[i]
		if node is CharacterBody2D and node.ground:
			var tempFrame = 1
			var tempPos = (global_position.x - node.global_position.x)
			if abs(tempPos) <= 8:
				tempFrame = 0
			if tempPos > 8:
				tempFrame = -1
			objectWeights.append(tempFrame)
	
	UpdateMappingsAndCollision(objectWeights,delta)
	
	# Players cannot spring eachother up; Players can spring the counterweight,
	# And counterweight can spring the players, but not vice-versa.
	

func UpdateMappingsAndCollision(array,delta):
	if !array:
		UpdateCollision(delta)
		return
	var temp = 0
	for i in array.size():
		temp += array[i]
	temp = clamp(temp,-1,1)
	if balance != temp:
		balance = temp
	UpdateCollision(delta)

func UpdateCollision(delta):
	match balance:
		-1:
			$CollisionShape2D.disabled = true
			$CollisionPolygon2D.disabled = false
			$CollisionPolygon2D2.disabled = true
		1:
			$CollisionShape2D.disabled = true
			$CollisionPolygon2D.disabled = true
			$CollisionPolygon2D2.disabled = false
		_:
			$CollisionShape2D.disabled = false
			$CollisionPolygon2D.disabled = true
			$CollisionPolygon2D2.disabled = true
	sprite.frame = balance+1
	if balance != balanceMemory:
		for i in weights.size():
			var node = weights[i]
			if node is CharacterBody2D:
				if balance == 0:
					node.global_position.y = (global_position.y - 52)
				elif balance < 0:
					node.global_position.y = (global_position.y - 52
					+ ((global_position.x - node.global_position.x)/1.5))
				else:
					node.global_position.y = (global_position.y - 52
					- ((global_position.x - node.global_position.x)/1.5))
	reactTime = LOCK_TIME



func physics_collision(body, hitVector):
	if hitVector.y > 0 and body.ground:
		if !weights.has(body):
			weights.append(body)
			print("PLAYER LAND")

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass #Now handled by physics collision
	if body == child:
		weights.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if weights.has(body):
		weights.erase(body)
		print("PLAYER LEAVE")



# Scrapped buggy code
func ScrapCode(delta):
	var balanceMemory = balance
	var directionMemory = direction
	balance = 0
	var tarcount = 0
	
	for i in weights.size():
		var node = weights[i]
		if node is CharacterBody2D and node.ground:
			tarcount+=1
			balance += (global_position.x - node.global_position.x)

	#The rest of the functions only run when function targets are in range.
	if tarcount > 0:
		balance = (balance/(tarcount+1)) #Always retrieve a value within range
		if balance > 12.0:
			direction = -1
		elif balance < -12.0:
			direction = 1
		else:
			direction = 0
		sprite.frame = 0-direction+1
		#Only if the change of balance is significanly different
		if ((balanceMemory>(balance+8) or balanceMemory<(balance-8)) and
		tarcount > 1 and directionMemory != direction):
			#direction = clamp(balanceMemory,-1,1)
			SpringObjectOnHighEnd()
	PositionCollisionSegment(delta)

#Update each CollisionShape
func PositionCollisionSegment(delta):
	var array = targetYPositions[sprite.frame]
	var nodeID = 0
	for i in get_child_count(false):
		if get_child(i) is CollisionShape2D:
			var node = get_child(i)
			if nodeID < array.size():
				if node.position.y < array[nodeID]:
					node.position.y +=(180*delta)
				if node.position.y > array[nodeID]:
					node.position.y -=(180*delta)
				if (node.position.y > (array[nodeID]+4)
				and node.position.y < (array[nodeID]-4)):
					node.position.y = array[nodeID]
				nodeID+=1
	
	pass

# Go through all weights; spring them upward based on the distance from the downward end.
func SpringObjectOnHighEnd():
	var downSide = direction*16
	var countedObjs = 0 #Compared to weights.size to see who landed last
	for i in weights.size():
		var node = weights[i]
		countedObjs +=1
		if node is CharacterBody2D and node.ground and countedObjs != weights.size():
			var yspeed = 0 - (min(32,abs(
			(node.global_position.x-round(global_position.x+downSide))
			)))*springPower
			if node.get("movement") != null:
				node.movement.y = yspeed
				if node.get("airControl") != null: #If this is true, the object is a player
					var curAnim = "walk"
					match(node.animator.current_animation):
						"walk", "run", "peelOut":
							curAnim = node.animator.current_animation
						# if none of the animations match and speed is equal beyond the players top speed, set it to run (default is walk)
						_:
							if(abs(node.groundSpeed) >= min(6*60,node.top)):
								curAnim = "run"
					node.set_state(node.STATES.AIR)
					node.airControl = true
					node.animator.play("spring")
					node.animator.queue(curAnim)
					Global.play_sound(springSound)
