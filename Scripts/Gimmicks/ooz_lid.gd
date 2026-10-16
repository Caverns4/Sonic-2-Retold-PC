extends Node2D

const POP_TIME = 1.0
const HOVER_TIME = 0.5

@onready var lid_cap: AnimatableBody2D = $AnimatableBody2D
## This is never actually used, but I like it so I'm keeping it here.
@onready var oil_funnel: TextureRect = $OilSlick
@onready var screen_check: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var burner_flames: Area2D = $BurnerFlames

var SFX: AudioStream = preload("res://Audio/SFX/Gimmicks/OOZ_Lid_Pop.wav")
var timer: float = POP_TIME

enum STATES{IDLE,HOVERING,LANDING}
var state: STATES = STATES.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VisibleOnScreenNotifier2D.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if screen_check.is_on_screen() or state > STATES.IDLE:
		timer -= delta
	
	match state:
		STATES.IDLE:
			if timer <= 0.0:
				timer = HOVER_TIME
				state = STATES.HOVERING
				SoundDriver.play_sound(SFX)
				lid_cap.movement.y = 0-(delta*480)
				burner_flames.activate()
		STATES.HOVERING:
			if lid_cap.movement.y < 0.0:
				lid_cap.movement.y += (9.8*delta)

			if timer <= 0.0:
				lid_cap.gravity = true
				burner_flames.deactivate()
				state = STATES.LANDING
				timer = 1.0
		STATES.LANDING:
			if (lid_cap.global_position.y >= global_position.y):
				lid_cap.worldPos = global_position
				lid_cap.gravity = false
				lid_cap.movement.y = 0.0
				state = STATES.IDLE
				timer = POP_TIME

	#Always keep the Lide in place just in case
	lid_cap.global_position.x = global_position.x
	#Position the Oil Funnel
	oil_funnel.global_position.y = lid_cap.global_position.y
	oil_funnel.size = Vector2(64,(global_position.y - lid_cap.global_position.y))
