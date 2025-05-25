extends EnemyBase

@export var bulletSound = preload("res://Audio/SFX/Gimmicks/s2br_ArrowFire.wav")
var Projectile = preload("res://Entities/Enemies/Projectiles/PterabotProjectile.tscn")

enum STATES{FLY,TARGET_PLAYER}
var state: int = STATES.FLY
var state_timer: float = 0.0
var droppedBomb: bool = false

func  _ready() -> void:
	super()
	velocity.y = -40

func _physics_process(delta: float) -> void:
	match state:
		STATES.FLY:
			var diff = GlobalFunctions.get_orientation_to_player(global_position)
			if abs(diff.x) < 128:
				state = STATES.TARGET_PLAYER
				velocity.y = -32
		STATES.TARGET_PLAYER:
			var diff = GlobalFunctions.get_orientation_to_player(global_position)
			if (diff.x > -16) and (diff.y >= 0.0) and !droppedBomb:
				droppedBomb = true
				# fire projectile
				Global.play_sound(bulletSound)
				var bullet = Projectile.instantiate()
				get_parent().add_child(bullet)
				# set position with offset
				bullet.global_position = global_position+Vector2(0,16)
