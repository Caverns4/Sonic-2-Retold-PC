extends Node2D

@export var neckSegments = 4
@export_enum("Left","Right") var direction = 0
@onready var head = $RexonHead
@onready var bulletPoint = $RexonHead/BulletPoint

var Projectile = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")
var bullet = null
@export var bulletSound = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")

var children:Array[Node2D] = [] #List of nodes for each child and the head
var childPositions:Array[Vector2] = [Vector2.ZERO] #position of each child and the head
var childVels:Array[Vector2] = [Vector2.ZERO]
var dead: bool = false
var swayDist:float = 0 #Gets manually set in code
var swayDirection:int = -1

func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
	direction = direction*2-1
	var currentPos = Vector2(20*direction,0)
	
	for i in max(0,neckSegments):
		var node = $Neck1.duplicate(8)
		add_child(node)
		children.append(node)
		childPositions.insert(childPositions.size(),currentPos)
		childVels.insert(childVels.size(),Vector2.ZERO)
		node.global_position = (global_position + currentPos)
		currentPos -= Vector2(0,12)
	$Neck1.queue_free()
	
	children.append(head)
	childPositions.insert(childPositions.size(),currentPos)
	childVels.insert(childVels.size(),Vector2.ZERO)
	head.global_position = (global_position + currentPos)

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
		UpdateDirection()
		#Sway back and forth, each node a little more intenseley.
		if (swayDist > 4.0 and swayDirection > 0):
			swayDirection = 0-swayDirection
		elif(swayDist < -12.0 and swayDirection < 0):
			swayDirection = 0-swayDirection
			ShootBullet()
		
		swayDist += sign(swayDirection) * (delta*6)
		#print(swayDist)
		var rememberedPosition = Vector2.ZERO
		for i in children.size():
			childPositions[i] = rememberedPosition.rotated(deg_to_rad(direction*swayDist))
			rememberedPosition = childPositions[i]-Vector2(0,12)
			if i == children.size():
				childPositions[i] -= Vector2(28*direction,12)
			else:
				childPositions[i] -= Vector2(24*direction,0)
			
	for i in children.size():
		childPositions[i] += childVels[i]
		children[i].global_position = global_position+childPositions[i]
	

func UpdateDirection():
	for i in get_child_count():
		get_child(i).scale.x = direction

func ShootBullet():
	#print("shoot")
	Global.play_sound(bulletSound)
	bullet = Projectile.instantiate()
	get_parent().add_child(bullet)
	# set position with offset
	bullet.global_position = bulletPoint.global_position
	bullet.scale.x = 1
	bullet.velocity.x = -100*direction
	bullet.gravity = true


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	var player_pos = GlobalFunctions.get_orientation_to_player(global_position)
	direction = 0-sign(player_pos.x - global_position.x)
