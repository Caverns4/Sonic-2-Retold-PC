extends Node2D
# timer used for time to a room change
var timer = 0
# active is set to true when the player enters the ring
var active = false

var player = null
var mask_memory = [0,0]

func _ready():
	# check that the current ring hasn't already been collected and all 7 emeralds aren't collected
	# the emerald check is so that it'll spawn if you have all emeralds anyway

	#if Global.nodeMemory.has(get_path()) and Global.emeralds < 127:
	#	print("An attempt to spawn a special ring failed")
	#	queue_free()
	#else:
	#	print("Spawn Special Ring")
	pass

func _process(delta):
	if active:
		# stop level timer (prevents time over)
		Global.timerActive = false
		# increase timer
		timer += delta
		if timer < 1.0 and timer+delta >= 1.0:
			active = false
			
			SoundDriver.music.stop()
			$Warp.play()
			# set next zone to current zone (this will reset when the stage is loaded back in)
			Global.nextZone = Global.main.lastScene
			
			# add ring to node memory so you can't farm the ring
			Global.nodeMemory.append(get_path())
			
			# fade to new scene
			Global.main.change_scene_to_file(
				load("res://Scene/SpecialStage/SpecialStage.tscn"),"WhiteOut","WhiteOut",1,true,false)
			# wait for scene to fade
			await Global.main.scene_faded
			player.allowTranslate = false
			player.set_state(player.STATES.NORMAL)
			player.collision_layer = mask_memory[0]
			player.collision_mask = mask_memory[1]
			SoundDriver.music.play(0.0)
			queue_free()
	# Spinning ring logic
	else:
		# loop the spawn animation
		if !$VisibleOnScreenNotifier2D.is_on_screen():
			$Ring.play("spawn")
		else:
			if !$Ring.is_playing():
				$Ring.play("default")


func _on_Hitbox_body_entered(body):
	# check if not active and that the player is player 1
	if !active and body.playerControl == 1:
		if Global.emeralds < 127:
			active = true
			player = body
			#body.visible = false
			body.movement = Vector2.ZERO
			# set players state to animation so nothing takes them out of it
			body.set_state(body.STATES.ANIMATION)
			# set player collision layer and mask to nothing to avoid collissions
			mask_memory[0] = body.collision_layer
			mask_memory[1] = body.collision_mask
			body.collision_layer = 0
			body.collision_mask = 0
			body.invTime = 0
			#$Hitbox/CollisionShape2D.disabled = true
		else:
			body.rings += 50
		
		# play sound
		$RingEnter.play()
		# play animation
		$Ring.play("enter")
		await $Ring.animation_finished
		# set visible to false after animation's complete
		visible = false
		$Hitbox/CollisionShape2D.disabled = true

# play spawning animation when the ring enters the screen
func _on_VisibilityNotifier2D_viewport_entered(_viewport):
	$Ring.play("spawn")
	$Ring.frame = 0
	await $Ring.animation_finished
	$Ring.play("default")
