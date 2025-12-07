extends Node2D

# next scene
@export var nextScene: String = "res://Scene/Presentation/Title.tscn"
# already changed is used to check that the powered by isn't already being skipped
var alreadyChanged = false
var globalTime = 0.0

func _ready():
	var rng: int = randi_range(0,255)
	if rng == Global.ZONES.DEATH_EGG:
		$CanvasLayer/Center/SilverSonic.visible = true
		$CanvasLayer/Center/Sonic.visible = false
	
	# delay so game can start
	await get_tree().create_timer(1.0).timeout
	
	# play title if the scene isn't already skipping
	if !alreadyChanged:
		$AnimationPlayer.play("Animation")
		#$Emerald.play()
		# wait for the animation to finish
		await $AnimationPlayer.animation_finished
		# do another check, if the scene's not already fading then fade to the next
		if !alreadyChanged:
			alreadyChanged = true
			$Warp.play()
			Main.change_scene(nextScene)

func _process(delta: float) -> void:
	globalTime += delta


func _input(event):
	# check if start gets pressed
	if event.is_action_pressed("gm_pause") and !alreadyChanged and globalTime > 1.5:
		alreadyChanged = true # used so that room skipping isn't doubled
		$Warp.play()
		Main.change_scene(nextScene)

func playDashSound():
	$DashSFX.play()

func playJingle():
	$Emerald.play()
