extends PlayerState

func _ready():
	invulnerability = true # ironic

func _physics_process(delta):
	# gravity
	parent.movement.y += parent.grv/GlobalFunctions.div_by_delta(delta)
	# do translate to avoid collision
	parent.translate = true
	
	if !Global.TwoPlayer:
		runDeathinSinglePlayer()
	else:
		runDeathInTwoPlayer()

func runDeathinSinglePlayer():
	# check if main player
	if parent.playerControl == 1:
		# check if speed above certain threshold
		if parent.movement.y > 1000 and Global.lives > 0 and !Global.gameOver:
			parent.movement = Vector2.ZERO
			Global.lives -= 1
			CheckGameOver(Global.lives,Global.levelTime)
	else:
	# if not run respawn code
		if parent.movement.y > 1000:
			parent.respawn()

func runDeathInTwoPlayer():
	if parent.playerControl == 1:
		if parent.movement.y > 1000 and Global.lives > 0 and !Global.gameOver:
			parent.movement = Vector2.ZERO
			Global.lives -= 1
			CheckGameOver(Global.lives,Global.levelTime)
	else:
		if parent.movement.y > 1000 and Global.livesP2 > 0 and !Global.gameOver:
			parent.movement = Vector2.ZERO
			Global.livesP2 -= 1
			CheckGameOver(Global.livesP2,Global.levelTimeP2)
	

func CheckGameOver(lifeCount,timerVal):
	# check if lives are remaining or death was a time over
	if lifeCount > 0 and timerVal < Global.maxTime:
		if !Global.TwoPlayer:
			Global.main.change_scene_to_file(null,"FadeOut")
			parent.process_mode = PROCESS_MODE_PAUSABLE
		else:
			RespawnInTwoPlayer()
	else:
		Global.gameOver = true
		# reset checkpoint time
		Global.checkPointTime = 0

func RespawnInTwoPlayer():
	invulnerability = false
	parent.translate = false
	parent.global_position = parent.respawnPosition
	parent.set_state(parent.STATES.NORMAL,parent.currentHitbox.NORMAL)
	parent.movement = Vector2.ZERO
	parent.velocity = Vector2.ZERO
	parent.airTimer = 1
	parent.animator.play("RESET")
	parent.collision_layer = parent.defaultLayer
	parent.collision_mask = parent.defaultMask
	parent.z_index = parent.defaultZIndex
	
