extends EnemyBase

#TODO: Decode behavior in ASM, avoid Super character
@onready var animation = $AnimationPlayer

enum STATES{WAITING,ROAMING,FLICKER,SHOCK,FADE,SETUP_ROAM,FLEE}
var state = STATES.WAITING
var stateTimer = 1.0
var currentPath: int = 0

# Copied from Sonic 2
var word_38810 = [256,416,520,645,768,832,912,1088]
var obj3a_DirectionsList = [
	Vector2(-1,1),
	Vector2(1,-1),
	Vector2(1,1),
	Vector2(1,-1),
	Vector2(-1,1),
	Vector2(1,-1),
	Vector2(-1,1),
	Vector2(-1,1),
]

func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true

func _physics_process(delta: float) -> void:
	stateTimer -= delta
	match state:
		STATES.WAITING:
			if stateTimer <= 0.0:
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
			# update facing direction
			velocity.x = move_toward(velocity.x,0,20*delta)
		STATES.FLICKER:
			pass
		STATES.SHOCK:
			if stateTimer <= 0:
				state=STATES.SETUP_ROAM
				animation.play("RESET")
		STATES.FADE:
			pass
		STATES.SETUP_ROAM:
			# Setup the next roaming path
			state = STATES.ROAMING
			stateTimer = 128.0/60
			var getVec = obj3a_DirectionsList[currentPath]
			#velocity.x = (word_38810[currentPath])
			velocity.x = (256.0/256*60) * getVec.x
			velocity.y = (40.0/256*60) * getVec.y
			
			if velocity.x > 0:
				$FlasherSprite.flip_h = true
			else:
				$FlasherSprite.flip_h = false
			
			currentPath += 1
			if currentPath >= obj3a_DirectionsList.size():
				velocity.x = (-256.0/256*60)
				velocity.y = (-40.0/256*60)
				state = STATES.FLEE

	$FlasherSprite.global_position.x = round(global_position.x)
	$FlasherSprite.global_position.y = round(global_position.y) 


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Flicker":
		state=STATES.SHOCK
		animation.play("Shock")
		stateTimer = 1.0
	if anim_name == "Fadeout":
		state=STATES.SETUP_ROAM
		animation.play("RESET")
