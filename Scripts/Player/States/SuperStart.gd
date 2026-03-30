extends PlayerState

var activated: bool = true

func _process(_delta: float) -> void:
	if activated and !parent.is_super:
		var remVel: Vector2 = parent.movement
		var lastAnim: String = parent.animator.current_animation
		# hide shield
		parent.shieldSprite.visible = false
		# set movement to 0
		parent.movement = Vector2.ZERO
		activated = false
		
		# play super animation
		parent.sfx[18].play()
		parent.animator.play("super")
		# wait for aniamtion to finish before activating super completely
		await parent.animator.animation_finished
		
		if parent.ground:
			parent.animator.play(lastAnim)
		else:
			parent.animator.play("walk")
		# enable control again
		parent.set_state(parent.STATES.AIR)
		# Reset Ring depletion time in case character goes super twice in a level.
		parent.superRingTimer = 1.0
		activated = true
		
		# swap sprite if sonic
		if parent.character == Global.CHARACTERS.SONIC:
			parent.sprite.texture = parent.superSprite
		# reset velocity to memory
		parent.movement = remVel
		parent.is_super = true
		parent.switch_physics()
		parent.super_time = 1
		# start super theme
		SoundDriver.playNormalMusic()
		
	# if already super just go to air state
	elif parent.is_super:
		parent.set_state(parent.STATES.AIR)
		

func state_exit() -> void:
	activated = true
	parent.strength = Global.STRENGTH_TIER.SUPER
