extends StaticBody2D

@export_enum("left","right") var startDirection = 1
@export var springPower = 20

@export var counterWeight = true
@export var counterWeightDamage = true
@export var counterWeightSprite = preload("res://Graphics/Enemies/CHIPPA.png")
# Image should be a horizonal sprite sheet with each frame being of equal width and height.
# It will cycle through frames at a consistent speed.

@onready var sprite = $Sprite2D
var springSound = preload("res://Audio/SFX/Gimmicks/s2br_Spring.wav")

const LOCK_TIME = 0.1 #Lock time after the See-Saw changes frame.

var child = null #Child Node if applicable.
var childCreated = false #Just in case so the child sprite won't get created twice.
var childRiding = false #If the Child should be treated as already on the see-saw.

var reactTime = 0 #Time for the See-Saw to stay idle
var balance =   0 # Current weight distribution
var balanceMemory = 0 #The last state of the platform
var weights = [] #Objects currently on the platform

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
		child.counterWeightSprite = counterWeightSprite
		child.updateImage()
		if startDirection <= 0:
			child.global_position.x -= 64
		if !counterWeightDamage:
			child.clearHurtbox()
	elif !counterWeight:
		$SolWeight.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	balanceMemory = balance
	clampChildXCoords()
	reactTime -= delta
	if reactTime > 0.0:
		#springObjectsOnBoard(delta)
		return
	UpdateMappingsAndCollision(delta)
	# Players cannot spring eachother up; Players can spring the counterweight,
	# And counterweight can spring the players, but not vice-versa.
	springObjectsOnBoard(delta)

func UpdateMappingsAndCollision(delta):
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
	
	if !objectWeights:
		UpdateCollision(delta)
		return
	var temp = 0
	for i in objectWeights.size():
		temp += objectWeights[i]
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
				var sizeNode = null
				for j in node.get_child_count(true):
					if node.get_child(j,true) is CollisionShape2D and !sizeNode:
						sizeNode = node.get_child(j,true)
				var nodeHeight = 0
				if sizeNode:
					nodeHeight = sizeNode.shape.size.y
				
				if balance == 0:
					node.global_position.y = (global_position.y - 32) - (nodeHeight/2)
				elif balance < 0:
					node.global_position.y = (global_position.y - 32
					+ ((global_position.x - node.global_position.x)/1.5)) - (nodeHeight/2)
				else:
					node.global_position.y = (global_position.y - 32
					- ((global_position.x - node.global_position.x)/1.5)) - (nodeHeight/2)
	reactTime = LOCK_TIME

func springObjectsOnBoard(delta):
	if !child or (weights.size() <= 1):
		return
	
	var downSide = balance*16
	var index = weights.size()-1 #Index if the last applicable weight.
	
	# If the last object is the counterweight, bounce each player object.
	#Should happen regardless of the state.
	if weights[index] == child and (childRiding == false):
		for i in weights.size()-1:
			var node = weights[i]
			if node.ground:
				var yspeed = abs(node.global_position.x-child.global_position.x)
				if yspeed <= 8:
					yspeed = 0
				elif yspeed <=32 and  yspeed>8:
					yspeed = -60
				else:
					yspeed = min(-60,-30*springPower)
				node.movement.y = yspeed
				
				node.set_state(node.STATES.AIR)
				node.airControl = true
				node.angle = 0
				node.animator.play("spring")
				node.animator.queue("curAnimwalk")
		SoundDriver.play_sound(springSound)
		childRiding = true

	# If the LAST object in weights is a player, bounce the counterweight if applicable.
	elif child.ground and balance != balanceMemory:
		var yspeed = 0 - (min(32,abs(
		(child.global_position.x-round(global_position.x+downSide))
		)))*springPower
		child.movement.y = yspeed
		childRiding = false
		reactTime = 0
		
		if child.global_position.x > global_position.x:
			child.movement.x = -60
		else:
			child.movement.x = 60
		
		UpdateMappingsAndCollision(delta)
	pass

func clampChildXCoords():
	child.global_position.x = clampi(child.global_position.x,global_position.x-32,global_position.x+32)

func physics_collision(body, hitVector):
	if hitVector.y > 0 and body.ground:
		body.angle = 0
		if !weights.has(body):
			weights.append(body)
			#print("PLAYER LAND")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == child:
		weights.append(body)
		#print("CHILD LAND")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if weights.has(body):
		weights.erase(body)
		#print("PLAYER LEAVE")
