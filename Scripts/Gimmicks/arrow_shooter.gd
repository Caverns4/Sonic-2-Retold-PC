extends Node2D

var Projectile = preload("res://Entities/Enemies/Projectiles/NGHZ_Arrow.tscn")
var bullet = null

enum STATES{IDLE,DETECT,FIRE}
var state = STATES.IDLE

@onready var anim = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ShootArrow():
	$AudioStreamPlayer.play()
	bullet = Projectile.instantiate()
	get_parent().add_child(bullet)
	# set position with offset
	bullet.global_position = global_position
	bullet.scale.x = 1
	bullet.velocity.x = 200

func _on_area_2d_body_entered(body: Node2D) -> void:
	if state == STATES.IDLE:
		state = STATES.DETECT
		anim.play("flash")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if state == STATES.DETECT:
		anim.play("open")
		state = STATES.FIRE


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "close":
		state = STATES.IDLE
		anim.play("default")
	if anim.animation == "open":
		ShootArrow()
		anim.play("close")
