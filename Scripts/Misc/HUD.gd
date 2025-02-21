extends CanvasLayer

## player ID look up
@export var focusPlayer: int = 0

# counter elements pointers
@onready var scoreText = $Counters/Text/ScoreNumber
@onready var timeText = $Counters/Text/TimeNumbers
@onready var ringText = $Counters/Text/RingCount
@onready var lifeText = $LifeCounter/Icon/LifeText
@onready var iconAnim = $Counters/Text/IconAnim

# play level card, if true will play the level card animator and use the zone name and zone text with the act
@export var playLevelCard: bool = true
@export var zoneName: String = "Base"
@export var zone: String = "Zone"
@export var act: int = 1

@export var waterSourceColor = preload("res://Graphics/Palettes/BasePal.png")
@export var waterReplaceColor = preload("res://Graphics/Palettes/WetPal.png")

@export var ringsForPerfect: int = 999 # Rings required for a perfect bonus. If the player takes damage, set to impossible value.


# used for flashing ui elements (rings, time)
var flashTimer = 0

# isStageEnding is used for level completion, stop loop recursions
var isStageEnding: bool = false

# level clear bonuses (check _on_CounterCount_timeout)
var timeBonus: int = 0
var ringBonus: int = 0
var perfectBonus: int = 0
var perfectEnabled: bool = true
var coins: int = 0 #Number of coins collected.

# gameOver is used to initialize the game over animation sequence, note: this is for animation, if you want to use the game over status it's in global
var gameOver: bool = false

# signal that gets emited once the stage tally is over
signal tally_clear

# character name strings, used for "[player] has cleared", this matches the players character ID so you'll want to add the characters name in here matching the ID if you want more characters
# see Global.PlayerChar1
var characterNames = ["SONIC","TAILS","KNUCKLES","AMY","MIGHTY","RAY"]

var twoPlayerResults = load("res://Scene/Presentation/TwoPlayerResults.tscn")

func _ready():
	if !Global.airSpeedCap:
		$Counters/Text.self_modulate = Color.RED
	# error prevention
	if !Global.is_main_loaded:
		return false
	$Water/WaterOverlay.material["shader_parameter/originalPalette"] = waterSourceColor
	$Water/WaterOverlay.material["shader_parameter/swapPalette"] = waterReplaceColor
	
	# stop timer from counting during stage start up and set global hud to self
	Global.timerActive = false
	Global.timerActiveP2 = false
	Global.hud = self

	var lifeCounterFrame = 0

	if Global.TwoPlayer:
		$Counters.visible = false
		$LifeCounter.visible = false
		$P1Counters.visible = true
		$P2Counters.visible = true
		# Set character Icon
		
		$P1Counters/LifeIcon.frame = Global.PlayerChar1
		$P2Counters/LifeIcon.frame = Global.PlayerChar2
		
		if Global.tailsNameCheat:
			if $P1Counters/LifeIcon.frame == 2:
				$P1Counters/LifeIcon.frame = 7
			if $P2Counters/LifeIcon.frame == 2:
				$P2Counters/LifeIcon.frame = 7
		
	else:
		$Counters.visible = true
		$LifeCounter.visible = true
		$P1Counters.visible = false
		$P2Counters.visible = false
		# Set character Icon
		if Global.livesMode:
			lifeCounterFrame = Global.PlayerChar1
			if lifeCounterFrame == 2 and Global.tailsNameCheat:
				lifeCounterFrame = 7
		else:
			lifeCounterFrame = 0
		$LifeCounter/Icon.frame = lifeCounterFrame
	
	# play level card routine if level card is true
	if !playLevelCard:
		$LevelCard/Banner.visible = false
		$LevelCard/PatternLeft.visible = false
		$LevelCard/RightRatio.visible = false
		$LevelCard/Zone.visible = false
		$LevelCard/LevelName.visible = false
		$LevelCard/Act.visible = false
		$"LevelCard/Retold Text".visible = false
		
	if 0 == 0:
		# set level card
		$LevelCard.visible = true
		# set level name strings
		$LevelCard/LevelName.text = zoneName
		$LevelCard/Zone.text = zone
		# set act graphic
		$LevelCard/Act.frame = act-1
		# make visible if act isn't 0 (0 will just be zone)
		if playLevelCard:
			$LevelCard/Act.visible = (act > 0)
		# make sure level card isn't paused so it can keep playing
		$LevelCard/CardPlayer.process_mode = PROCESS_MODE_ALWAYS
		# temporarily let music play during pauses
		if Global.musicParent != null:
			Global.musicParent.process_mode = PROCESS_MODE_ALWAYS
		# pause game while card is playing
		get_tree().paused = true
		# play card animations
		$LevelCard/CardPlayer.play("Start")
		$LevelCard/CardMover.play("Slider")
		# wait for card to finish it's entrance animation, then play the end
		await $LevelCard/CardPlayer.animation_finished
		$LevelCard/CardPlayer.play("End")
		# unpause the game and set previous pause mode nodes to stop on pause
		get_tree().paused = false
		respawnPlayer()
		Global.musicParent.process_mode = PROCESS_MODE_PAUSABLE
		$LevelCard/CardPlayer.process_mode = PROCESS_MODE_PAUSABLE
		# emit stage start signal
		Global.emit_stage_start()
		# wait for title card animator to finish ending before starting the level timer
		await $LevelCard/CardPlayer.animation_finished
		Global.main.sceneCanPause = true
	else:
		get_tree().paused = true
		await get_tree().process_frame # delay unpausing for one frame so the player doesn't die immediately
		await get_tree().process_frame # second one needed for player 2
		# emit the stage start signal and start the stage
		Global.emit_stage_start()
		get_tree().paused = false
	Global.timerActive = true
	Global.timerActiveP2 = true
	# replace "sonic" in stage clear to match the player clear string
	$LevelClear/SonicGot.text = characterNames[Global.PlayerChar1-1] + " GOT"
	if Global.tailsNameCheat and Global.PlayerChar1 == Global.CHARACTERS.TAILS:
		$LevelClear/SonicGot.text = "MILES GOT"
	
	# set the act clear frame
	$LevelClear/Act.frame = act-1

func respawnPlayer():
	if Global.players:
		var player = Global.players[0]
		# set player's position to rings (and player 2)
		# helps sell the illusion that we reset the room
		if Global.checkPoints.size() > 0:
			for i in Global.checkPoints:
				if Global.currentCheckPoint == i.checkPointID:
					#print(i.checkPointID)
					player.camera.global_position = i.global_position+Vector2(0,8)
					player.global_position = i.global_position+Vector2(0,8)
					Global.levelTime = Global.checkPointTime
					Global.levelTimeP2 = Global.checkPointTime
					Global.lastSpecialStageResult = false
		player.direction = 1
		# Remember to give the player's air back, they might have been under water
		# imagine if you were underwater and got sucked into another dimension only for when
		# you get back you immediately drown.
				# That's happened in real life plenty of times they just never tell you about it
				# mostly because the people this has happened to have drowned.
				# But this is Sonic the Hedgehog and not real life so this unrealistic change is fine
		player.airTimer = player.defaultAirTime
		# check for partner
		if player.partner:
			player.partner.global_position = player.global_position+Vector2(-32,0)
			player.partner.direction = 1
			player.partner.movement = Vector2.ZERO
			player.partner.velocity = Vector2.ZERO
			# reset state
			player.partner.set_state(player.partner.STATES.NORMAL)
			# play idle
			player.partner.animator.play("idle")
			# reset the partners air, imagine if you came home and from another dimension and-
			player.partner.airTimer = player.partner.defaultAirTime
				
		# reset invincibility and shoes (or super low so they player can exit these states normally)
		player.supTime = min(player.supTime,0.01)
		player.shoeTime = min(player.supTime,0.01)
		player.switch_physics()
		player.visible = true
		# reset state
		player.set_state(player.STATES.NORMAL)
		# play idle
		player.animator.play("idle")
		player.collision_layer = player.defaultLayer
		player.collision_mask = player.defaultMask


func _process(delta):
	# set score string to match global score with leading 0s
	scoreText.text = "%6d" % Global.score
	
	# clamp time so that it won't go to 10 minutes
	var timeClamp = min(Global.levelTime,Global.maxTime-1)
	# set time text, format it to have a leadin 0 so that it's always 2 digits
	#timeText.text = "%2d" % floor(timeClamp/60) + ":" + str(fmod(floor(timeClamp),60)).pad_zeros(2)
	# uncomment below (and remove above line) for mili seconds
	timeText.text = "%2d" % floor(timeClamp/60) + ":" + str(fmod(floor(timeClamp),60)).pad_zeros(2) + ":" + str(fmod(floor(timeClamp*100),100)).pad_zeros(2)
	$P1Counters/Text/TimeNumbers.text = timeText.text
	timeClamp = min(Global.levelTimeP2,Global.maxTime-1)
	$P2Counters/Text/TimeNumbers.text = "%2d" % floor(timeClamp/60) + ":" + str(fmod(floor(timeClamp),60)).pad_zeros(2) + ":" + str(fmod(floor(timeClamp*100),100)).pad_zeros(2)
	
	# check that there's player, if there is then track the focus players ring count
	var playerCount = Global.players.size()
	if (playerCount > 0):
		ringText.text = "%3d" % Global.players[focusPlayer].rings
		$P1Counters/Text/RingCount.text = "%3d" % Global.players[0].rings
	if (playerCount > 1):
		$P2Counters/Text/RingCount.text = "%3d" % Global.players[1].rings
		
	
	# track lives with leading 0s
	if Global.livesMode:
		lifeText.text = "%3d" % Global.lives
	else:
		lifeText.text = "%3d" % min(Global.totalCoins + coins,999)
	if Global.TwoPlayer:
		$P1Counters/LifeIcon/LifeText.text = "%3d" % Global.lives
		$P2Counters/LifeIcon/LifeText.text = "%3d" % Global.livesP2
	
	if $Timer.time_left > 0:
		$DeathTimers/CountdownP1.text = str(ceil($Timer.time_left))
		$DeathTimers/CountdownP2.text = str(ceil($Timer.time_left))
	
	# Water Overlay
	
	# cehck that this level has water
	if Global.waterLevel != null:
		# get current camera
		var cam = GlobalFunctions.getCurrentCamera2D()
		if !Global.TwoPlayer:
			if cam != null:
				# if camera exists place the water's y position based on the screen position as the water is a UI overlay
				$Water/WaterOverlay.position.y = clamp(
					Global.waterLevel-GlobalFunctions.getCurrentCamera2D().get_screen_center_position().y+(get_viewport().get_visible_rect().size.y/2
					),0,get_viewport().get_visible_rect().size.y)
			# scale water level to match the visible screen
			$Water/WaterOverlay.scale.y = clamp(Global.waterLevel-$Water/WaterOverlay.position.y,0,get_viewport().size.y)
			$Water/WaterOverlay.visible = true
		else:
			# if camera exists place the water's y position based on the screen position as the water is a UI overlay
			$Water/WaterOverlay.position.y = clamp(
				Global.waterLevel-GlobalFunctions.getCurrentCamera2D().get_screen_center_position().y+(get_viewport().get_visible_rect().size.y/4
				),0,get_viewport().get_visible_rect().size.y/2)
			# scale water level to match the visible screen
			$Water/WaterOverlay.scale.y = clamp(Global.waterLevel-$Water/WaterOverlay.position.y,0,get_viewport().size.y)
			$Water/WaterOverlay.visible = true
		
		# Water Overlay Elec flash
		if (Global.players.size() > 0):
			# loop through players
			for i in Global.players:
				# check if in water and has elec or fire shield
				if i.water:
					match (i.shield):
						i.SHIELDS.ELEC:
							# reset shield do flash
							i.set_shield(i.SHIELDS.NONE)
							$Water/WaterOverlay/ElecFlash.visible = true
							# destroy all enemies in near player and below water
							for j in get_tree().get_nodes_in_group("Enemy"):
								if j.global_position.y >= Global.waterLevel and i.global_position.distance_to(j.global_position) <= 256:
									if j.has_method("destroy"):
										Global.add_score(j.global_position,Global.SCORE_COMBO[0],Global.players.find(i))
										j.destroy()
							# disable flash after a frame
							await get_tree().process_frame
							$Water/WaterOverlay/ElecFlash.visible = false
						i.SHIELDS.FIRE:
							# clear shield
							i.set_shield(i.SHIELDS.NONE)
	else:
		# disable water overlay
		$Water/WaterOverlay.visible = false
	
	
	# HUD flashing text
	if flashTimer < 0 and Global.airSpeedCap:
		flashTimer = 0.1
		if Global.players.size() > 0:
			# if ring count at zero, flash rings
			if Global.players[focusPlayer].rings <= 0:
				$Counters/Text/Rings.visible = !$Counters/Text/Rings.visible
			else:
				$Counters/Text/Rings.visible = false
		# if minutes up to 9 then flash time
		if Global.levelTime >= 60*9:
			$Counters/Text/Time.visible = !$Counters/Text/Time.visible
		else:
			$Counters/Text/Time.visible = false
	elif !get_tree().paused:
		flashTimer -= delta
	
	# stage clear handling
	if Global.stageClearPhase > 0 and Global.main.sceneCanPause:
		Global.main.sceneCanPause = false
	if Global.stageClearPhase > 2:
		# initialize stage clear sequence
		if !isStageEnding:
			isStageEnding = true
			if Global.players[0].totalRings >= ringsForPerfect and perfectEnabled:
				$LevelClear/PerfectBonusText.visible = true
				perfectBonus = 50000
			
			# show level clear elements
			$LevelClear.visible = true
			$LevelClear/TotalText/TallyTotal.text = scoreText.text
			$LevelClear/Animator.play("LevelClear")
			
			# set bonuses
			ringBonus = floor(Global.players[focusPlayer].rings)*100
			$LevelClear/RingBonusText/RingBonus.text = "%6d" % ringBonus
			$LevelClear/PerfectBonusText/PerfectBonus.text = "%6d" % perfectBonus
			timeBonus = 0
			# bonus time table
			var bonusTable = [
			[60*5,500],
			[60*4,1000],
			[60*3,2000],
			[60*2,3000],
			[60*1.5,4000],
			[60,5000],
			[45,10000],
			[30,50000],
			]
			# loop through the bonus table, if current time is less then the first value then set it to that bonus
			# you'll want to make sure the order of the table goes down in time and up in score otherwise it could cause some weirdness
			for i in bonusTable:
				if Global.levelTime < i[0]:
					timeBonus = i[1]
			# set bonus text for time
			$LevelClear/TimeBonusText/TimeBonus.text = "%6d" % timeBonus
			# wait for counter wait time to count down
			$LevelClear/CounterWait.start()
			await $LevelClear/CounterWait.timeout
			# start the level counter tally (see _on_CounterCount_timeout)
			$LevelClear/CounterCount.start()
			await self.tally_clear
			# wait 2 seconds (reuse timer)
			$LevelClear/CounterWait.start(2)
			await $LevelClear/CounterWait.timeout
			Global.totalCoins += coins
			# after clear, change to next level in Global.nextZone (you can set the next zone in the level script node)
			Global.loadNextLevel()
			Global.main.change_scene_to_file(Global.nextZone,"FadeOut","FadeOut",1)
	
	# game over sequence
	elif Global.gameOver and !gameOver:
		# set game over to true so this doesn't loop
		gameOver = true
		# determine if the game over is a time over (game over and time over sequences are the same but game says time)
		if Global.levelTime >= Global.maxTime:
			$GameOver/Game.frame = 1
		# play game over animation and play music
		$GameOver/GameOver.play("GameOver")
		$GameOver/GameOverMusic.play()
		# stop normal music tracks
		Global.music.stop()
		Global.life.stop()
		# wait for animation to finish
		await $GameOver/GameOver.animation_finished
		# reset game
		if Global.levelTime < Global.maxTime or (Global.lives <= 0 and Global.livesMode):
			if Global.TwoPlayer:
				var results = [Global.score,Global.levelTime,Global.players[0].rings,
				Global.scoreP2,Global.levelTimeP2,Global.players[1].rings]
				Global.twoPlayActResults.append(results)
				#Set flag to load the results screen.
				#print(results)
				Global.main.change_scene_to_file(twoPlayerResults,"FadeOut")
			else:
				Global.main.change_scene_to_file(Global.startScene,"FadeOut")
			await Global.main.scene_faded
			Global.reset_values()
		# reset level (if time over and lives aren't out)
		else:
			Global.main.change_scene_to_file(null,"FadeOut")
			await Global.main.scene_faded
			Global.levelTime = 0
			Global.levelTimeP2 = 0
			
			

# counter count down
func _on_CounterCount_timeout():
	# play counter sound
	$LevelClear/Counter.play()
	
	# decrease bonuses in order, if time bonus not 0 then count time down, then do the same for rings
	# if you add other bonuses (like perfect bonus) you'll want to add it to the end of the sequence before the end
	if timeBonus > 0:
		# check if adding score would hit the life bonus
		Global.check_score_life(100)
		timeBonus -= 100
		Global.score += 100
	elif ringBonus > 0:
		# check if adding score would hit the life bonus
		Global.check_score_life(100)
		ringBonus -= 100
		Global.score += 100
	elif perfectBonus > 0:
		# check if adding score would hit the life bonus
		Global.check_score_life(100)
		perfectBonus -= 100
		Global.score += 100
	else:
		# stop counter timer and play score sound
		$LevelClear/Counter.play()
		$LevelClear/CounterCount.stop()
		$LevelClear/Score.play()
		# emit tally clear signal
		emit_signal("tally_clear")
	# set the level clear strings to the bonuses
	$LevelClear/TotalText/TallyTotal.text = scoreText.text
	$LevelClear/TimeBonusText/TimeBonus.text = "%6d" % timeBonus
	$LevelClear/PerfectBonusText/PerfectBonus.text = "%6d" % perfectBonus
	$LevelClear/RingBonusText/RingBonus.text = "%6d" % ringBonus

func InitTimerForPlayer(index):
	if index == 0:
		$DeathTimers/CountdownP1.visible = true
	if index == 1:
		$DeathTimers/CountdownP2.visible = true
	$Timer.start()


func _on_timer_timeout() -> void:
	if Global.timerActive:
		Global.players[0].kill(true)
		Global.timerActive = false
		Global.gameOver = true
	if Global.timerActiveP2:
		Global.players[1].kill(true)
		Global.timerActiveP2 = false
		Global.gameOver = true
	#If neither are true, then both players made it past the goal.
