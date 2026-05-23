extends Node2D

@export var sprite: Texture2D = preload("res://Graphics/Gimmicks/SCZ_ShiftingPlatform1.png")
@export var tilt_time: float = 1.0

@onready var platform: AnimatableBody2D = $ShiftingPlatformChild
@onready var screen_checker: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

var target_angle: float = 0.0

func _physics_process(delta: float) -> void:
	if platform.rotation_degrees != target_angle:
		platform.rotation_degrees = move_toward(platform.rotation_degrees,target_angle,delta*240)
		platform.set_collision_disable( abs(platform.rotation_degrees) >= 35.0 )


func _do_tilt(contact_x: float) -> void:
	if target_angle != 0.0: return
	var diff: float = sign(contact_x - global_position.x)
	if diff != 0:
		await get_tree().create_timer(tilt_time/2.0).timeout
		target_angle = 90*diff
		await get_tree().create_timer(tilt_time).timeout
		target_angle = 0.0


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	platform.rotation_degrees = 0.0
	platform.set_collision_disable(false)
	target_angle = 0.0
