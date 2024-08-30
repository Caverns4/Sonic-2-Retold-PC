extends StaticBody2D

@onready var sprite = $Sprite2D

var weights = [] #Objects currently on the platform
var balanceMemory = 0.0 # Saved weight distribution
var balance = 0.0 # Current weight distribution
var direction = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	balanceMemory = balance
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
		if balance > 8.0:
			direction = -1
		elif balance < -8.0:
			direction = 1
		else:
			direction = 0
		sprite.frame = 0-direction+1
		#Only if the change of balance is significanly different
		if (balanceMemory>(balance+16) or
		balanceMemory<(balance-16)) and tarcount > 1:
			#direction = clamp(balanceMemory,-1,1)
			SpringObjectOnHighEnd()

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
			)))*16
			if node.get("movement") != null:
				node.movement.y = yspeed
			elif node.get("velocity") != null:
				node.velocity.y = yspeed
			#print(node.movement.y/16)
	
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	weights.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	weights.erase(body)
