extends CharacterBody2D

@export_enum("default","laugh","hurt") var animation: String = "default"
@export var jet = false

var savedAnim = "deafult"

var timer = 0.0

@onready var eggman = $Eggmobile/Eggman_Face
@onready var fire = $Eggmobile/Eggmobile_Fire

func _ready() -> void:
	eggman.play(animation)
	savedAnim = animation
	fire.visible = jet

func _physics_process(delta: float) -> void:
	timer += delta
	
	if jet and wrapf(timer,0.0,1.0/60) > (1.0/30):
		fire.visible = true
	else:
		fire.visible = false
	
	if animation != savedAnim:
		eggman.play(animation)
		savedAnim = animation
	
