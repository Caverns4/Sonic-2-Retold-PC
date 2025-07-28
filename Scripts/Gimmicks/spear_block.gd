extends AnimatableBody2D

@export var switch_time: float = 1.0
@export_enum("Counter-Clockwise","Clockwise") var direction = 1
@export var sfx = preload("res://Audio/SFX/Objects/s2br_Spikes.wav")

@onready var spear: Area2D = $Spear

var timer = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spear.monitoring = false
	$VisibleOnScreenEnabler2D.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		SoundDriver.play_sound(sfx)
		timer = 1.0
		if spear.monitoring:
			spear.monitoring = false
		else:
			spear.rotation_degrees += 90.0*direction
			spear.monitoring = true
	
	if spear.monitoring:
		spear.global_position = spear.global_position.move_toward(
			global_position+(
				Vector2.from_angle(spear.rotation - deg_to_rad(90))*32),
			256*delta)
		
	else:
		spear.global_position = spear.global_position.move_toward(
			global_position,256*delta)
