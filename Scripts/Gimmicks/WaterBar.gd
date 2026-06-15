extends Area2D

# Vertical Swinging Bar from Mushroom Hill Zone
# Author: Sharb (this is a modified version of the Vertical Bar by DimensionWarped)

# Sound to play when the bar is grabbed
@export var grabSound: AudioStream = preload("res://Audio/SFX/Player/s2br_Grab.wav")
# Sound to play when bar broken
@export var collapseSFX: AudioStream = preload("res://Audio/SFX/Gimmicks/s2br_Collapse.wav")

@export var break_parts: Array[CharacterBody2D] = []

# How many seconds before the bar breaks
@export var strength: float = 3.0
# Used for reseting the bar strength
@onready var startStrength: float = strength

var players: Array[Player2D] = [] # Tracks the players that are active within the gimmick


func _ready() -> void:
	$Grab.stream = grabSound

# check for players and if the jump button is pressed, release them from the poll
func _process(_delta: float) -> void:
	for i: Player2D in players:
		if i.any_action_pressed():
			remove_player(i)
			break_apart()
	

func _physics_process(delta: float) -> void:
	# Iterate through every player to see if they should be mounted to the bar
	for i: Player2D in players:
		if !(check_grab(i)):
			continue
			
		# ignore if player is dead
		if i.currentState == i.STATES.DIE:
			break
		i.sprite.flip_h = (i.movement.x < 0)
		
		# Drop all the speed values to 0 to prevent issues.
		i.groundSpeed = 0
		i.movement.x = 0
		# this gimmick needs to be used in conjunction with the wind current,
		# vertical movement is handled by the current so we just slow it down here
		i.movement.y = i.movement.y*0.25
		i.cam_update()
	
	for i: Player2D in players:
		if i.currentState == i.STATES.ANIMATION:
			i.global_position.x = global_position.x
	# decrease strength if any players are holding
	if players.size() > 0:
		if strength > 0:
			strength -= delta
		else:
			break_apart()


func break_apart() -> void:
	# play sound globally (prevents sound overlap, aka loud sounds)
	SoundDriver.play_sound(collapseSFX)
	# directiont the players moving in
	var releaseDirection: int = 1
	# release players
	for i: Player2D in players:
	# set release direction to the players direction
		releaseDirection = i.direction
		remove_player(i)
	# create sprite particles
	for i in break_parts:
		i.reparent(get_parent())
		i.launch_in_direction(releaseDirection)
	queue_free() # delete

func check_grab(player: Player2D) -> bool:
	# Skip if already on the vertical bar or player is jumping
	if (player.currentState == player.STATES.ANIMATION):
		return true
	return false


func _on_VerticalBarArea_body_entered(player: Player2D) -> void:
	if player != get_parent(): #check that parent isn't going to be carried
		if !players.has(player):
			players.append(player)
			$Grab.play()
			# use offset vertical bar cling if the sprite is flipped
			player.set_state(player.STATES.ANIMATION, player.currentHitbox.HORIZONTAL)
			#if player.sprite.flip_h:
			#	player.animator.play("clingVerticalBarOffset")
			#else:
			player.animator.play("clingVerticalBar")

func _on_VerticalBarArea_body_exited(player: Player2D) -> void:
	remove_player(player)
	
func remove_player(player: Player2D) -> void:
	if players.has(player):
		# reset player animation
		player.animator.play("current")
		# Clean out the player from all player-linked arrays.
		players.erase(player)
