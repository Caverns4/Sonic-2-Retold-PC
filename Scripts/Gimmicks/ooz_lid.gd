extends Node2D

const POP_TIME = 1.0
const HOVER_TIME = 0.5

@onready var Lid = $AnimatableBody2D
@onready var Funnel = $TextureRect
@onready var OnScreen = $VisibleOnScreenNotifier2D
@onready var Flames = $BurnerFlames

var SFX = preload("res://Audio/SFX/Gimmicks/OOZ_Lid_Pop.wav")
var timer = POP_TIME

enum STATES{IDLE,HOVERING,LANDING}
var state = STATES.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VisibleOnScreenNotifier2D.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if OnScreen.is_on_screen() or state > STATES.IDLE:
		timer -= delta
	
	match state:
		STATES.IDLE:
			if timer <= 0.0:
				timer = HOVER_TIME
				state = STATES.HOVERING
				Global.play_sound(SFX)
				Lid.movement.y = 0-(delta*480)
				Flames.activate()
		STATES.HOVERING:
			if Lid.movement.y < 0.0:
				Lid.movement.y += (9.8*delta)

			if timer <= 0.0:
				Lid.gravity = true
				Flames.deactivate()
				state = STATES.LANDING
				timer = 1.0
		STATES.LANDING:
			if (Lid.global_position.y >= global_position.y):
				Lid.worldPos = global_position
				Lid.gravity = false
				Lid.movement.y = 0.0
				state = STATES.IDLE
				timer = POP_TIME

	#Always keep the Lide in place just in case
	Lid.global_position.x = global_position.x
	#Position the Oil Funnel
	Funnel.global_position.y = Lid.global_position.y
	Funnel.size = Vector2(64,(global_position.y - Lid.global_position.y))
