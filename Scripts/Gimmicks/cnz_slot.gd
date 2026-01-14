extends Node2D

@export_enum("Points Only", "Slot Machine") var type = 0

var SFX = preload("res://Audio/SFX/Objects/s2br_CNZSlot.wav")

var ringprize = preload("res://Entities/Gimmicks/Ring_Prize.tscn")
var spikeprize = preload("res://Entities/Gimmicks/spike_prize.tscn")

const POINTS_TIME = 1.0

var player: Player2D = null
var timer = 2.0 # Not used for Character reels, that will be signal-based.
var sfxTimer = 0.0

enum SLOT{SONIC_NULL,TAILS,KNUCKLES,EGGMAN,RING,JACKPOT,SONIC}

enum STATES{NONE,WAITING_REEL,GIVING_PRIZE,PRIZE_GIVEN}
var state = STATES.NONE

var reels = []
var prizes: int = 0
var prize_spawn_angle = 0
var prize_nodes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type > 0:
		Global.slot_machines.append(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		timer -= delta
		$Sprite2D.frame = wrapi(round(timer*60),0,1)
		
		for i in prize_nodes:
			if !is_instance_valid(i):
				prize_nodes.erase(i)
		
		match type:
			0:
				if timer > 0.0:
					sfxTimer -= delta
					if sfxTimer < 0.0:
						SoundDriver.play_sound(SFX)
						sfxTimer = 0.25
						Global.add_score(global_position,1,
						Global.players.find(player))
				else:
					dropPlayer()
			_:
				match state:
					STATES.WAITING_REEL:
						sfxTimer -= delta
						if sfxTimer < 0.0:
							SoundDriver.play_sound(SFX)
							sfxTimer = 0.25
					STATES.GIVING_PRIZE:
						if prizes != 0:
							timer -= delta
							if timer < 0:
								timer = 0.1
								for i in 8:
									if prizes != 0:
										var prize = ringprize.instantiate()
										if prizes < 0:
											prize = spikeprize.instantiate()
										prize.target = player
										prize.global_position = global_position + (Vector2.UP*256).rotated(prize_spawn_angle)
										prize_spawn_angle += 45
										get_parent().add_child(prize)
										prize_nodes.append(prize)
										prizes = move_toward(prizes,0,1)
						if prizes == 0 and !prize_nodes:
							state = STATES.PRIZE_GIVEN
							Global.character_reels.is_in_use = false
							Global.character_reels.idle_timer = 5.0
							timer = 1.0
					STATES.PRIZE_GIVEN:
						timer -= delta
						if timer < 0:
							dropPlayer()
							state = STATES.NONE


func reward_player():
	if !player:
		return
	if player == Global.players[0] or Global.two_player_mode:
		state = STATES.GIVING_PRIZE
		prizes = Parse_Prize()
	else:
		dropPlayer()
		state = STATES.NONE

func dropPlayer():
	if player:
		#Reset this cage
		$Sprite2D.frame = 0
		timer = POINTS_TIME
		state = STATES.NONE
		sfxTimer = 0.0
		#Free the player
		player.set_state(player.STATES.AIR,player.currentHitbox.ROLL)
		player.airControl = true
		player.controlObject = null
		player.allowTranslate = false
		player = null


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !player:
		player = body
		body.set_state(body.STATES.ANIMATION)
		body.animator.play("roll")
		body.global_position = global_position
		body.movement = Vector2.ZERO
		body.controlObject = self
		state = STATES.WAITING_REEL
		if type > 0 and !Global.character_reels.is_in_use:
			reels = determine_each_slot()
			Global.character_reels.roll_character_slots(reels,self)

func determine_each_slot():
	var a = randi_range(1,SLOT.size()-1)
	var b = randi_range(1,SLOT.size()-1)
	var c = randi_range(1,SLOT.size()-1)
	
	var p = randi_range(0,100)
	# 10% chance of trips
	if p < 10:
		b = a
		c = a
	elif p < 20:
		c = a
	elif p < 30:
		b = a
	elif p < 40:
		b = SLOT.RING
	elif p > 95:
		b = SLOT.JACKPOT
		c = SLOT.JACKPOT
	
	var d = [a,b,c]
	return d

func Parse_Prize():
	var ring_reward = 0
	# 5 rings per Ring
	for i in reels:
		if i == SLOT.RING:
			ring_reward += 5
	var compare = 1
	for jack in reels:
		if jack == SLOT.JACKPOT:
			compare +=1
	ring_reward *= compare
	# If the player got even one Ring, they can't have gotten any other outcome.
	if ring_reward:
		return ring_reward
	# 3 jackpots alwas == 100 rings.
	if reels == [SLOT.JACKPOT,SLOT.JACKPOT,SLOT.JACKPOT]:
		ring_reward = 100
		return ring_reward
	
	compare = 0
	# Set up the base reward
	if reels.has(SLOT.SONIC):
		ring_reward = 50
		compare = SLOT.SONIC
	elif reels.has(SLOT.TAILS):
		ring_reward = 30
		compare = SLOT.TAILS
	elif reels.has(SLOT.KNUCKLES):
		ring_reward = 20
		compare = SLOT.KNUCKLES
	elif reels.has(SLOT.EGGMAN):
		ring_reward = -100
		compare = SLOT.EGGMAN
	# Check if there are any characters that break the chain.
	for character in reels:
		if character != compare and character != SLOT.JACKPOT:
			ring_reward = 0
	# Times for the number of Jackpots if any
	var num_jackpots = reels.count(SLOT.JACKPOT)
	ring_reward *= (num_jackpots+1)
	
	return ring_reward
