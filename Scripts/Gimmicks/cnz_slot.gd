extends Node2D

@export_enum("Points Only", "Slot Machine") var type = 0

var SFX = preload("res://Audio/SFX/Objects/s2br_CNZSlot.wav")

const POINTS_TIME = 2.0

var player = null
var timer = 2.0 # Not used for Character reels, that will be signal-based.
var sfxTimer = 0.0

enum SLOT{SONIC,TAILS,KNUCKLES,EGGMAN,RING,JACKPOT}

enum STATES{NONE,GIVING_PRIZE,PRIZE_GIVEN}
var state = STATES.NONE
var prizeGiven = false
var prizeSelected = false
var prizes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type > 0:
		Global.slotMachines.append(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		timer -= delta
		$Sprite2D.frame = wrapi(round(timer*60),0,1)

		if timer > 0.0 and !prizeSelected:
			sfxTimer -= delta
			if sfxTimer < 0.0:
				Global.play_sound(SFX)
				sfxTimer = 0.25
				if Global.two_player_mode:
					Global.add_score(global_position,1,
					Global.players.find(player))
				else:
					Global.add_score(global_position,1,0)

		if timer < 0.0 and (type == 0 or prizeGiven):
			dropPlayer()

func reward_player(result: Array):
	if player and !prizeSelected:
		print("Prizes: " + str(result))
		DeterminPrize(result)
		state = STATES.GIVING_PRIZE
		prizeSelected = true
		#temp
		prizeGiven = true
		timer = 0.5

func dropPlayer():
	if player:
		#Reset this cage
		$Sprite2D.frame = 0
		timer = POINTS_TIME
		state = STATES.NONE
		prizeGiven = false
		prizeSelected = false
		sfxTimer = 0.0
		#Free the player
		player.set_state(player.STATES.AIR)
		player.controlObject = null
		player = null

func DeterminPrize(result):
	
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	if !player:
		player = body
		body.set_state(body.STATES.ANIMATION)
		body.animator.play("roll")
		body.global_position = global_position
		body.movement = Vector2.ZERO
		body.controlObject = self
		if type > 0:
			timer = 3.0
			var a = randi_range(0,SLOT.size()-1)
			var b = randi_range(0,SLOT.size()-1)
			var c = randi_range(0,SLOT.size()-1)
			var d = [a,b,c]
			
			for i in Global.characterReels:
				if i.has_method("roll_character_slots"):
					i.roll_character_slots(d)
