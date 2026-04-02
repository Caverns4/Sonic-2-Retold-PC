extends Node2D

# next scene
@export var nextScene: String = "res://Scene/Presentation/Title.tscn"
# already changed is used to check that the powered by isn't already being skipped
var ending_scene: bool = false
var globalTime: float = 0.0

func _ready() -> void:
	Global.debug_mode = false
	var rng: int = randi_range(0,255)
	if rng == Global.ZONES.DEATH_EGG:
		$CanvasLayer/Center/SilverSonic.visible = true
		$CanvasLayer/Center/Sonic.visible = false
	
	# delay so game can start
	await get_tree().create_timer(1.0).timeout
	
	# play title if the scene isn't already skipping
	if !ending_scene:
		$AnimationPlayer.play("Animation")
		#$Emerald.play()
		# wait for the animation to finish
		await $AnimationPlayer.animation_finished
		# do another check, if the scene's not already fading then fade to the next
		await end_scene()

func _process(delta: float) -> void:
	globalTime += delta


func _input(event: InputEvent) -> void:
	if ending_scene or globalTime < 1.0:
		return
	# check if start gets pressed
	if event.is_action_pressed("ui_pause"):
		await end_scene()
	elif event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			await end_scene()

func end_scene() -> void:
	ending_scene = true
	$Warp.play()
	await Main.change_scene(nextScene,"WhiteOut",1,false)

func playDashSound() -> void:
	$DashSFX.play()

func playJingle() -> void:
	$Emerald.play()
