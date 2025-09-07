extends EnemyBase

#TODO: Decode behavior in ASM, avoid Super character
@onready var animation = $AnimationPlayer
@onready var murder_zone = $SubSprite/Area2D
@onready var damage_zone = $DamageArea
@onready var sprite = $FlasherSprite

enum STATES{WAITING,ROAMING,FLICKER,SHOCK,FADE,SETUP_ROAM,FLEE}
var state = STATES.WAITING
var stateTimer = 1.0
var currentPath: int = 0

# Copied from Sonic 2
var word_38810 = [
	256/60,
	416/60,
	520/60,
	645/60,
	768/60,
	832/60,
	912/60,
	1088/60]
var byte_38820 = [
	Vector2(-1,1),
	Vector2(1,-1),
	Vector2(1,1),
	Vector2(1,-1),
	Vector2(-1,1),
	Vector2(1,-1),
	Vector2(-1,1),
	Vector2(-1,1),
]
# Some labels copied from Sonic 2 Retold to make porting easier.
var obj3a_subTimer = 0.0 #Count up to 60ths/sec
var obj3a_LifeTime = 0 
var obj3a_VelIndex = 0


func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true

func _physics_process(delta: float) -> void:
	stateTimer -= delta
	match state:
		STATES.WAITING:
			if stateTimer <= 0.0:
				# ObjA3_MoveStart
				state = STATES.ROAMING
				velocity.x = (-256.0/256*60)
				velocity.y = (40.0/256*60)
				stateTimer = 128.0/60 
				#RememberState
		STATES.ROAMING:
			if stateTimer < 0.0:
				#Setup Flicker
				state = STATES.FLICKER
				animation.play("Flicker")
				velocity = Vector2.ZERO
				return
			#Setup direction
			sprite.flip_h = (velocity.x > 0)
			var obj3a_deceleration = 20*delta
			obj3a_LifeTime += delta
			if word_38810[obj3a_VelIndex] < obj3a_LifeTime:
				var d1 = clampi(obj3a_VelIndex+1,0,word_38810.size()-1)
				obj3a_VelIndex = d1
				var a1 = byte_38820[d1]
				if a1.x > 0:
					obj3a_deceleration = 0-obj3a_deceleration
				if sign(a1.y) != sign(velocity.y):
					velocity.y = 0-velocity.y
			#velocity.x = move_toward(velocity.x,0,20*delta)
			velocity.x += obj3a_deceleration
		#Turn on/off (Await animation)
		STATES.FLICKER:
			pass
		STATES.SHOCK:
			if stateTimer <= 0.0:
				state=STATES.FLICKER
				animation.play("FadeOut")
				damage_zone.monitoring = true
				murder_zone.monitorable = false
		STATES.SETUP_ROAM:
			# Setup the next roaming path
			# ObjA3_MoveStart
			state = STATES.ROAMING
			stateTimer = 128.0/60
			velocity.x = (-256.0/256*60)
			velocity.y = (-40.0/256*60)
			
			if obj3a_VelIndex < byte_38820.size()-1:
				var a1 = byte_38820[obj3a_VelIndex]
				velocity.x *= a1.x
				velocity.y = (40.0/256*60) * a1.y
			else:
				sprite.flip_h = (velocity.x > 0)
				velocity.y = 0-velocity.y
				state = STATES.FLEE

	sprite.global_position.x = round(global_position.x)
	sprite.global_position.y = round(global_position.y) 


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Flicker":
		state=STATES.SHOCK
		animation.play("Shock")
		stateTimer = 1.0
		damage_zone.monitoring = false
		murder_zone.monitorable = true
	if anim_name == "FadeOut":
		state=STATES.SETUP_ROAM
		animation.play("RESET")
