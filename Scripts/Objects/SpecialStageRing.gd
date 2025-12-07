extends Node2D
# timer used for time to a room change
var timer = 0
# active is set to true when the player enters the ring
var active = false

var player:Player2D = null
var mask_memory = [0,0]

func _ready():
	# check that the current ring hasn't already been collected and all 7 emeralds aren't collected
	# the emerald check is so that it'll spawn if you have all emeralds anyway
	if Global.object_table.has(get_path()) or Global.emeralds > 127:
		queue_free()

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
			# Set up level memory so Sonic won't lose level progress.
			Global.object_table.append(get_path())
			Global.save_level_data(global_position)
			
			# fade to new scene
			Main.change_scene("res://Scene/SpecialStage/SpecialStage.tscn","WhiteOut",1,false)
			await Main.scene_faded
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
			player.visible = false
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
