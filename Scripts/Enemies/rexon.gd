extends Node2D

@export var neckSegments = 4
@onready var head = $RexonHead
@onready var bulletPoint = $RexonHead/BulletPoint

var Projectile = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")
var bullet = null
@export var bulletSound = preload("res://Audio/SFX/Objects/Projectile.wav")

var oscilationValue = 0 #Make the segments sway aback and forth

var children = [] #List of nodes for each child and the head
var childPositions = [Vector2.ZERO] #position of each child and the head
var childVels = [Vector2.ZERO]
var dead = false
var swayDist = 0 #Gets manually set in code
var direction = -1

func _ready() -> void:
	var currentPos = Vector2(-20,0)
	children.append($Neck1)
	childPositions[0] = currentPos
	
	for i in max(0,neckSegments):
		var node = $Neck1.duplicate(8)
		add_child(node)
		children.append(node)
		childPositions.insert(childPositions.size(),currentPos)
		childVels.insert(childVels.size(),Vector2.ZERO)
		node.position = (global_position + currentPos)
		currentPos -= Vector2(0,12)
	
	children.append(head)
	childPositions.insert(childPositions.size(),currentPos)
	childVels.insert(childVels.size(),Vector2.ZERO)
	head.global_position = (global_position + currentPos)
	#print(childPositions)

func _process(delta: float) -> void:
	if !head and !dead:
			dead = true
			children.resize(children.size()-1)
			
			var splitVar = delta*9.8 * childVels.size()
			for i in childVels.size():
				childVels[i].y = splitVar
				splitVar -= delta*9.8
	
	if dead:
		for i in childVels.size():
			childVels[i].y += delta*9.8
	else:
		#Sway back and forth, each node a little more intenseley.
		if (swayDist > 4.0 and direction > 0):
			direction = 0-direction
		elif(swayDist < -12.0 and direction < 0):
			direction = 0-direction
			ShootBullet()
		
		swayDist += sign(direction) * (delta*6)
		#print(swayDist)
		var rememberedPosition = Vector2.ZERO
		for i in children.size():
			childPositions[i] = rememberedPosition.rotated(deg_to_rad(swayDist))
			rememberedPosition = childPositions[i]-Vector2(0,12)
			if i == children.size():
				childPositions[i] -= Vector2(28,12)
			else:
				childPositions[i] -= Vector2(24,0)
			
	for i in children.size():
		childPositions[i] += childVels[i]
		children[i].global_position = global_position+childPositions[i]

func ShootBullet():
	#print("shoot")
	Global.play_sound(bulletSound)
	bullet = Projectile.instantiate()
	get_parent().add_child(bullet)
	# set position with offset
	bullet.global_position = bulletPoint.global_position
	bullet.scale.x = 1
	bullet.velocity.x = -100*(global_scale.x)
	bullet.gravity = true
