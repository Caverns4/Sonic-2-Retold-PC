extends Node2D
const MAX_LIFETIME = 256.0/60.0
var scattered: bool = false
var lifetime: float = MAX_LIFETIME
var velocity: Vector2 = Vector2.ZERO
var player: Player2D
var magnet: Area2D = null
var magnetShape: CollisionObject2D = null
var ringacceleration: Array[float] = [0.75,0.1875]
var Particle: PackedScene = preload("res://Entities/Misc/GenericParticle.tscn")

func _ready() -> void:
	if Global.object_table.has(get_path()):
		queue_free()

func _process(delta: float) -> void:
	# scattered logic
	if (scattered):
		z_index = 7
		$RingSprite.speed_scale = lifetime / MAX_LIFETIME + 1
		if (lifetime > 0):
			lifetime -= delta
		else:
			queue_free()
	if (player):
		# collect ring
		if (player.ringDisTime <= 0):
			z_index = 1
			# get ring to player
			player.get_ring()
			if !scattered:
				Global.object_table.append(get_path())
			var part: AnimatedSprite2D = Particle.instantiate()
			get_parent().add_child(part)
			part.global_position = global_position
			part.play("RingSparkle")
			queue_free()

func _physics_process(delta: float) -> void:
	# scattered physics logic
	if (scattered):
		velocity.y += 0.09375*60.0
		translate(velocity*delta)
		if ($FloorCheck.is_colliding() and velocity.y > 0):
			velocity.y *= -0.75
	elif (magnet):
		#relative positions
		var sx: int = sign(magnet.global_position.x - global_position.x)
		var sy: int = sign(magnet.global_position.y - global_position.y)
		
		#check relative movement
		var tx: int = int(sign(velocity.x) == sx)
		var ty: int = int(sign(velocity.y) == sy)
		
		#add to speed
		velocity.x += (ringacceleration[tx] * sx)/GlobalFunctions.div_by_delta(delta)
		velocity.y += (ringacceleration[ty] * sy)/GlobalFunctions.div_by_delta(delta)
		translate(velocity*delta)
		if magnetShape.disabled:
			scattered = true
		#"ringacceleration" would be an array, where: [0] = 0.75 [1] = 0.1875
		
		

func _on_Hitbox_body_entered(body: Player2D) -> void:
	if (player != body):
		if (!scattered) or (scattered and lifetime < (3.3)):
			player = body


func _on_Hitbox_body_exited(body: Player2D) -> void:
	if (player == body):
		player = null


func _on_Hitbox_area_shape_entered(_area_id: int, area:Area2D, _area_shape:CollisionShape2D, _local_shape: CollisionShape2D) -> void:
	if (magnet == null):
		magnet = area
		magnetShape = area.get_child(0)
