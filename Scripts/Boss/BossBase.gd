class_name BossBase extends CharacterBody2D

@export_enum("Normal", "Fire", "Elec", "Water") var damageType: int = 0
var playerHit: Array = []

@export var hp: int = 8
@export var hit_time: float = 32.0/60.0
@export var boss_name: String = "Eggman"
@export var explosion_radius: Vector2 = Vector2(32,32)

@export_group("Components")
@export var flashing_sprite: Sprite2D = null

var direction: int = -1 #left is -1, right is 1

const DEATH_TIME: float = 4.0

var forceDamage: bool = false
var vulnerable: bool = true
var defeated_flag: bool = false

var Explosion: PackedScene = preload("res://Entities/Misc/GenericParticle.tscn")
var hoverOffset: float = 0.0

@onready var flash_time: Timer = $Timers/FlashTime
# This wil also control the time until the boss flees after the final hit.
@onready var animation_timer: Timer = $Timers/AnimationTime
@onready var smoke_timer: Timer = $Timers/SmokeTimer
@onready var eggman_face: AnimatedSprite2D = $EggMobile/Robotnik
var animationPriority: Array[StringName] = ["default","move","laugh","hit","exploded"]

signal got_hit
signal hit_player
signal flash_finished
signal boss_defeated
signal boss_over
signal boss_started
signal destroyed

var active: bool = false: set = boss_start
func boss_start(value: bool) -> void:
	if value:
		boss_started.emit()
	active = value


func _ready() -> void:
	if Global.two_player_mode:
		queue_free()
	else:
		flash_time.timeout.connect(_on_flash_timer_timeout)
		animation_timer.timeout.connect(_on_animation_timer_timeout)
		smoke_timer.timeout.connect(_on_smoke_timer_timeout)
		boss_defeated.connect(on_first_defeat)

func _physics_process(delta: float) -> void:
	if active and hp > 0 and vulnerable:
		update_flashing(delta)
		
		# loop through player hit as i
		for i: Player2D in playerHit:
			# check if damage entity is on or supertime is bigger then 0
			if (i.is_attacking() or i.super_time > 0 or forceDamage):
				knockoff_player(i)
				if hp > 0: _boss_hit()
			# if destroying the enemy fails and hit player exists then hit player
			elif i.hit_player(global_position,damageType):
				emit_signal("hit_player")


func knockoff_player(i: Player2D) -> void:
	i.movement = i.movement*-1 #i.movement*-0.5
	# check if gliding, if they are force them to fall
	if i.currentState == i.STATES.GLIDE:
		i.animator.play("glideFall")
		# reset player hitbox
		i.set_hitbox(i.currentHitbox.NORMAL)
		i.reflective = false
		if i.get_node_or_null("States/Glide") != null:
			i.get_node("States/Glide").isFall = true

func update_flashing(_delta:float) -> void:
	if !flashing_sprite: return
	# flashing for the egg mobile 
	if !vulnerable and hp > 0:
		flashing_sprite.visible = !flashing_sprite.visible
	else:
		flashing_sprite.visible = false

func _boss_hit() -> void:
	hp -= 1
	if hp > 0:
		$Hit.play()
		vulnerable = false
		set_animation("hit",hit_time)
		flash_time.start(hit_time)
		emit_signal("got_hit")
	else:
		emit_signal("got_hit")
		boss_defeated.emit()


func _on_body_entered(body: Player2D) -> void:
	# add to player list
	if (!playerHit.has(body)):
		playerHit.append(body)


func _on_body_exited(body: Player2D) -> void:
	# remove from player list
	if (playerHit.has(body)):
		playerHit.erase(body)

# Run when the final hit is dealth
func on_first_defeat() -> void:
	defeated_flag = true
	flash_time.start(DEATH_TIME)
	set_animation("exploded",DEATH_TIME)
	velocity = Vector2.ZERO
	smoke_timer.start(0.01667*7)

func updateDirection() -> void:
	if direction > 0:
		$EggMobile.scale.x = -1
	else:
		$EggMobile.scale.x = 1

# Laugh for 1 second
func do_laugh() -> void:
	set_animation("laugh",1)

# animation to play, time is how long the animation should play for until it stops
func set_animation(animation: StringName = "default", time: float = 0.0) -> void:
	if animationPriority.has(animation) and eggman_face.is_playing():
		var animID: int = animationPriority.find(animation)
		var currentAnimID: int = animationPriority.find(eggman_face.animation)
		if animID < currentAnimID:
			return
	if eggman_face: eggman_face.play(animation)
	if time: animation_timer.start(time)


# Updated to allow precise calculate per-frame(hopefully)
func updateHoveringPos(delta: float) -> void:
	# change the hover offset
	global_position.y = global_position.y-hoverOffset
	hoverOffset = move_toward(hoverOffset,cos(Global.levelTime*4)*4,delta*10)
	call_deferred("restore_hover_pose")

func restore_hover_pose() -> void:
	global_position.y = global_position.y+hoverOffset

func _on_DamageArea_area_entered(area: Area2D) -> void:
	# damage checking
	if area.get("parent") != null and area.is_attacking():
		if !playerHit.has(area.parent):
			forceDamage = true
			playerHit.append(area.parent)


func _on_HitBox_area_exited(area: Area2D) -> void:
	# remove from damage area
	if area.get("parent") != null:
		if playerHit.has(area.parent):
			playerHit.erase(area.parent)

func _on_flash_timer_timeout() -> void:
	if hp > 0:
		emit_signal("flash_finished")
		vulnerable = true
	else:
		await start_defeated_phase()

func start_defeated_phase() -> void:
	smoke_timer.stop()
	await get_tree().create_timer(1.0).timeout
	_mark_defeated()

func _mark_defeated() -> void:
	boss_over.emit()
	destroyed.emit()

func _on_animation_timer_timeout() -> void:
	if defeated_flag:
		smoke_timer.stop()
	eggman_face.stop()
	if velocity.x != 0:
		set_animation("move")
	elif !defeated_flag:
		set_animation("default")

func _on_smoke_timer_timeout() -> void:
	# play explosion sound
	$Explode.play()
	# spawn exposion particles
	var expl: Node2D = Explosion.instantiate()
	# set animation
	expl.play("BossExplosion")
	expl.z_index = 10
	# add object
	get_parent().add_child(expl)
	# set position reletive to us
	expl.global_position = global_position+Vector2(
		randf_range(-explosion_radius.x,explosion_radius.x),
		randf_range(-explosion_radius.y,explosion_radius.y))
