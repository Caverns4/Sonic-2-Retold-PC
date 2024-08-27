@tool
extends CharacterBody2D

var physics = false
var grv = 0.21875
var yspeed = 0
var playerTouch = null
var isActive = true
@export_enum("Ring", "Speed Shoes", "Invincibility", "Shield", "Elec Shield", "Fire Shield",
"Bubble Shield", "Super", "Teleport", "Boost","Eggman","?", "Extra Life", "Tails Life") var item = 0

enum ITEMTYPES{RING,SPEED_SHOES,INVINCIBILITY, SHIELD, ELECSHIELD, FIRESHIELD,
BUBBLESHIELD,SUPER,TELEPORT,BOOST,EGGMAN,QMARK,LIFEP1,LIFEP2}

var twoPlayerItems = [
	ITEMTYPES.RING,
	ITEMTYPES.SPEED_SHOES,
	ITEMTYPES.INVINCIBILITY,
	ITEMTYPES.SHIELD,
	ITEMTYPES.TELEPORT
]

var Explosion = preload("res://Entities/Misc/BadnickSmoke.tscn")


func _ready():
	if !Engine.is_editor_hint():
		if Global.TwoPlayer:
			item = ITEMTYPES.QMARK
	
		# set frame
		$Item.frame = item+2
		# Life Icon (life icons are a special case)
		if item == ITEMTYPES.LIFEP1 and !Engine.is_editor_hint():
			$Item.frame = item + 1 + Global.PlayerChar1
		if item == ITEMTYPES.LIFEP2 and !Engine.is_editor_hint():
			$Item.frame = item + Global.PlayerChar2
	

func _process(_delta):
	# update for editor
	if Engine.is_editor_hint():
		$Item.frame = item+2

func destroy():
	# skip if not activated
	if !isActive:
		return false
	# create explosion
	var explosion = Explosion.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	# deactivate
	isActive = false
	
	# set item to have a high Z index so it overlays a lot
	$Item.z_index += 1000
	# play destruction animation
	$Animator.play("DestroyMonitor")
	$SFX/Destroy.play()
	# wait for animation to finish
	await $Animator.animation_changed
	# enable effect
	match (item):
		ITEMTYPES.RING: # Rings
			playerTouch.rings += 10
			$SFX/Ring.play()
		ITEMTYPES.SPEED_SHOES: # Speed Shoes
			if !playerTouch.get("isSuper"):
				playerTouch.shoeTime = 20
				playerTouch.switch_physics()
				Global.currentTheme = 1
				Global.effectTheme.stream = Global.themes[Global.currentTheme]
				Global.effectTheme.play()
		ITEMTYPES.INVINCIBILITY: # Invincibility
			if !playerTouch.get("isSuper"):
				playerTouch.supTime = 20
				playerTouch.shieldSprite.visible = false # turn off barrier for stars
				playerTouch.get_node("InvincibilityBarrier").visible = true
				Global.currentTheme = 0
				Global.effectTheme.stream = Global.themes[Global.currentTheme]
				Global.effectTheme.play()
		ITEMTYPES.SHIELD: # Shield
			playerTouch.set_shield(playerTouch.SHIELDS.NORMAL)
		ITEMTYPES.ELECSHIELD: # Elec
			playerTouch.set_shield(playerTouch.SHIELDS.ELEC)
		ITEMTYPES.FIRESHIELD: # Fire
			playerTouch.set_shield(playerTouch.SHIELDS.FIRE)
		ITEMTYPES.BUBBLESHIELD: # Bubble
			playerTouch.set_shield(playerTouch.SHIELDS.BUBBLE)
		ITEMTYPES.SUPER: # Super
			playerTouch.rings += 50
			if !playerTouch.get("isSuper"):
				playerTouch.set_state(playerTouch.STATES.SUPER)
		ITEMTYPES.LIFEP1: # 1up
			Global.life.play()
			Global.lives += 1
			Global.effectTheme.volume_db = -100
			Global.music.volume_db = -100
		ITEMTYPES.LIFEP2: #2-Player 1up
			Global.life.play()
			Global.livesP2 +=1
			Global.effectTheme.volume_db = -100
			Global.music.volume_db = -100
		ITEMTYPES.EGGMAN:
			playerTouch.kill(false)
		ITEMTYPES.QMARK:
			pass


func _physics_process(delta):
	if !Engine.is_editor_hint():
		# if physics are on make em fall
		if physics:
			var collide = move_and_collide(Vector2(0,yspeed)*delta)
			yspeed += grv/GlobalFunctions.div_by_delta(delta)
			if collide and yspeed > 0:
				physics = false

# physics collision check, see physics object
func physics_collision(body, hitVector):
	# Monitor head bouncing
	if hitVector.y < 0:
		yspeed = -1.5*60
		physics = true
		if body.movement.y < 0:
			body.movement.y *= -1
	# check that player has the rolling layer bit set
	elif body.get_collision_layer_value(20):
		# Bounce from below
		if hitVector.x != 0:
			# check conditions for interaction (and the player is the first player)
			if body.movement.y >= 0 and body.movement.x != 0 and (body.playerControl == 1 or Global.TwoPlayer):
				playerTouch = body
				destroy()
			else:
				# Stop horizontal movement
				body.movement.x = 0
		# check if player is not an ai or spindashing
		# if they are then destroy
		if (body.playerControl == 1 or Global.TwoPlayer) and body.currentState != body.STATES.SPINDASH:
			body.movement.y = -abs(body.movement.y)
			
			if body.currentState == body.STATES.ROLL:
				body.movement.y = 0
			body.ground = false
			playerTouch = body
			destroy()
		else:
			body.ground = true
			body.movement.y = 0
	return true

# insta shield should break instantly
func _on_InstaArea_area_entered(area):
	if area.get("parent") != null and isActive:
		playerTouch = area.parent
		area.parent.movement.y *= -1
		destroy()
