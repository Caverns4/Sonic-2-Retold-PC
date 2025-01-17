extends Node2D

const POP_TIME = 1.0
const HOVER_TIME = 2.0

@onready var Lid = $CharacterBody2D
@onready var Funnel = $TextureRect
@onready var OnScreen = $VisibleOnScreenNotifier2D

var SFX = preload("res://Audio/SFX/Gimmicks/OOZ_Lid_Pop.wav")
var timer = POP_TIME

enum STATES{IDLE,HOVERING,LANDING}
var state = STATES.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
				Lid.velocity.y = -320
				Lid.spinning = true
		STATES.HOVERING:
			if Lid.velocity.y < 0.0:
				Lid.velocity.y += (0.09375/GlobalFunctions.div_by_delta(delta))
			if timer <= 0.0:
				Lid.gravity = true
				state = STATES.LANDING
				timer = 1.0
		STATES.LANDING:
			if Lid.is_on_floor() or timer <= 0.0:
				Lid.global_position = global_position
				Lid.gravity = false
				Lid.spinning = false
				Lid.velocity.y = 0.0
				state = STATES.IDLE
				timer = POP_TIME

	#Always keep the Lide in place just in case
	Lid.global_position.x = global_position.x
	#Position the Oil Funnel
	Funnel.global_position.y = Lid.global_position.y
	Funnel.size = Vector2(64,(global_position.y - Lid.global_position.y))
