extends BossBase

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	# defeated animation timer (default time is 3 seconds)
	if defeated_flag:
		# if above 0 then count down
		if deathTimer > 0:
			# count down
			deathTimer -= delta
			# start running away once timer hits 0
			if deathTimer <= 0:
				_mark_defeated()

func _on_smoke_timer_timeout() -> void:
	# check that deathtimer's still going and that we are actually defeated
	if defeated_flag and deathTimer > 1.5:
		# play explosion sound
		$Explode.play()
		# spawn exposion particles
		var expl: AnimatedSprite2D = Explosion.instantiate()
		# set animation
		expl.play("BossExplosion")
		expl.z_index = 10
		# add object
		get_parent().add_child(expl)
		# set position reletive to us
		expl.global_position = global_position+Vector2(randf_range(-32,32),randf_range(-32,32))

func _on_boss_defeated() -> void:
	super()
	$SmokeTimer.start(0.01667*7)
