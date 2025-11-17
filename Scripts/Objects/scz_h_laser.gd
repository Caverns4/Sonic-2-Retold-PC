extends CharacterBody2D

@export var speed: float = 64
@export var sfx = preload("res://Audio/SFX/Objects/s2br_BigLaser.wav")

func _ready() -> void:
	velocity.x = -speed


func _physics_process(_delta: float) -> void:
	if $VisibleOnScreenNotifier2D.is_on_screen():
		move_and_slide()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	SoundDriver.play_sound(sfx)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#if !Global.players:
	#	return
	#if global_position.x > ((global_position.x - Global.players[0].position.x)*sign(speed)):
		queue_free()


func _on_laser_area_body_entered(body: Node2D) -> void:
	if body is Player2D:
		var this: Player2D = body
		this.hit_player(global_position,Global.DAMAGE_TYPES.FIRE)
	elif body is Tornado2D:
		var this: Tornado2D = body
		this._damage_plane()
