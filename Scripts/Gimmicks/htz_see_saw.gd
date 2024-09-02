extends StaticBody2D

@export var springPower = 20

@onready var sprite = $Sprite2D
var springSound = preload("res://Audio/SFX/Gimmicks/Springs.wav")

var weights = [] #Objects currently on the platform
var balance = 0.0 # Current weight distribution
var direction = 0

var targetYPositions =[
	[-40,-36,-32,-28,-24,-20,-16,-12, -8,-4 ,  0], #Heavy on right
	[-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24], #Centered
	[  0, -4, -8,-12,-16,-20,-24,-28,-32,-36,-40]  #Heavy on Left
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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
				
			elif node.get("velocity") != null:
				node.velocity.y = yspeed
				if node.get("lobForce") != null:
					node.lobForce = 4.0*sign(global_position.x-node.global_position.x)
					#print(4.0*sign(global_position.x-node.global_position.x))
					#node.velocity.x = 4.0*sign(global_position.x-node.global_position.x)
			#print(node.movement.y/16)


func _on_area_2d_body_entered(body: Node2D) -> void:
	weights.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	weights.erase(body)
