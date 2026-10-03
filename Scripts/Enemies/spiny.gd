extends EnemyBase

## Total distance travelled in pixels
@export var x_range: int = 80
const speed = 20.0

const bullet_sfx: AudioStream = preload("res://Audio/SFX/Objects/s2br_Projectile.wav")
const projectile: PackedScene = preload("res://Entities/Enemies/Projectiles/GenericProjectile.tscn")

@onready var bulletPoint: Node2D = $Sprite2D/BulletPoint
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var origin: Vector2 = global_position

var side: int = -1
var shoot_delay: float = 0.0
var movement_locked: bool = false
var target_pos: Vector2 = Vector2.ZERO
var targets: Array[Player2D] = []


func _ready() -> void:
	if !Engine.is_editor_hint():
		var direction: Vector2 = Vector2(x_range*clamp(side,-1,0),0).rotated(deg_to_rad(rotation_degrees))
		target_pos = origin + direction
		super()
		animator.play("WALK")
		$PlayerCheck.visible = true


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	shoot_delay -= delta
	
	if shoot_delay <= 0.0 and targets:
		var player: Player2D = targets[0]
		animator.play("RESET")
		shoot_delay = 2.0
		movement_locked = true
		await get_tree().create_timer(0.25).timeout
		_shoot_bullet(player)
		await get_tree().create_timer(0.25).timeout
		movement_locked = false
		return
	
	if movement_locked: return
	# move position toward origin point with the travel distance
	if side <= 0:
		position = position.move_toward(
			origin-Vector2(x_range,0).rotated(deg_to_rad(rotation_degrees)),
			speed*delta)
	else:
		position = position.move_toward(origin,speed*delta)

	# if at the destination point, turn around
	if position.distance_to(target_pos) <= 1:
		#Calculate a new Target position
		side = -side
		if side <= 0:
			target_pos = origin + Vector2(x_range*clamp(side,-1,0),0).rotated(deg_to_rad(rotation_degrees))
		else:
			target_pos = origin
		animator.play("WALK")
		shoot_delay = 0.0


func _shoot_bullet(current_target: Player2D) -> void:
	var bullet: CharacterBody2D = projectile.instantiate()
	add_child(bullet)
	bullet.top_level = true
	bullet.gravity = true
	bullet.global_position = bulletPoint.global_position
	SoundDriver.play_sound(bullet_sfx)
	var temp: Vector2 = Vector2(0,-150).rotated(rotation)
	var balance: int = sign(current_target.global_position.x - global_position.x)
	temp = Vector2(0,150).rotated(balance * -40)
	bullet.velocity = temp


func _on_player_check_body_entered(body: Node2D) -> void:
	if body is Player2D:
		targets.append(body)


func _on_player_check_body_exited(body: Node2D) -> void:
	if body is Player2D:
		targets.erase(body)
