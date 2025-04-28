@tool
extends CharacterBody2D

var physics = false
var grv = 0.21875
var yspeed = 0
var playerTouch = null
var isActive = true

## The Item Type contained by default.
@export_enum("Ring", "Speed Shoes", "Invincibility", "Shield", "Elec Shield", "Fire Shield",
"Bubble Shield", "Super", "Teleport", "Boost","Eggman","?", "Extra Life", "Tails Life") var item = 0

## The shield this monitor will give the player if they have a shield already.
@export_enum("None", "Elec Shield", "Fire Shield", "Bubble Shield") var shieldAffinity = 0

enum ITEMTYPES{RING,SPEED_SHOES,INVINCIBILITY, SHIELD, ELECSHIELD, FIRESHIELD,
BUBBLESHIELD,SUPER,TELEPORT,BOOST,EGGMAN,QMARK,LIFEP1,LIFEP2}

var twoPlayerItems = [
	ITEMTYPES.RING,
	ITEMTYPES.RING,
	ITEMTYPES.SPEED_SHOES,
	ITEMTYPES.INVINCIBILITY,
	ITEMTYPES.SHIELD,
	ITEMTYPES.TELEPORT,
	ITEMTYPES.EGGMAN,
	ITEMTYPES.LIFEP1,
	ITEMTYPES.LIFEP2
]

var Explosion = preload("res://Entities/Misc/BadnickSmoke.tscn")


func _ready():
	if !Engine.is_editor_hint():
		if Global.two_player_mode:
			item = ITEMTYPES.QMARK
		# set frame
		$Item.frame = item+2
		# Life Icon (life icons are a special case)
		if item == ITEMTYPES.LIFEP1 and !Engine.is_editor_hint():
			if Global.livesMode:
				$Item.frame = item+2 + Global.PlayerChar1
		if item == ITEMTYPES.LIFEP2 and !Engine.is_editor_hint():
			var nextFrame = item+1 + Global.PlayerChar2
			#if Global.PlayerChar2 < Global.CHARACTERS.SONIC:
			#	nextFrame = item + 1
			$Item.frame = nextFrame
			
	

func _process(_delta):
	# update for editor
	if Engine.is_editor_hint():
		$Item.frame = item+2
		if item == ITEMTYPES.LIFEP1:
			$Item.frame = item+3
		if item == ITEMTYPES.LIFEP2:
			$Item.frame = item+3

func FrameUpdate():
	$Item.frame = item+2

func destroy():
	# skip if not activated
	if Global.two_player_mode:
		match Global.twoPlayerItems:
			Global.ITEM_MODE.ALL_KINDS_ITEMS:
				item = twoPlayerItems.pick_random()
				$Item.frame = item+2
				if item == ITEMTYPES.LIFEP1:
					$Item.frame = item + 1 + Global.PlayerChar1
				if item == ITEMTYPES.LIFEP2:
					$Item.frame = item + Global.PlayerChar2
			Global.ITEM_MODE.TELEPORT_ONLY:
				item = ITEMTYPES.TELEPORT
				$Item.frame = item+2
			Global.ITEM_MODE.RING_ONLY:
				item = ITEMTYPES.RING
				$Item.frame = item+2
			Global.ITEM_MODE.EGGMAN_ONLY:
				item = ITEMTYPES.EGGMAN
				$Item.frame = item+2
			_:
				pass


	
	if item == ITEMTYPES.SHIELD and !Global.two_player_mode and playerTouch.shield > 0:
		if shieldAffinity == 1:
			item = ITEMTYPES.ELECSHIELD
		if shieldAffinity == 2:
			item = ITEMTYPES.FIRESHIELD
		if shieldAffinity == 3:
			item = ITEMTYPES.BUBBLESHIELD
		else:
			var rand = randi_range(0,2)
			if rand == 0:
				item = ITEMTYPES.ELECSHIELD
			elif rand == 1:
				item = ITEMTYPES.FIRESHIELD
			elif rand == 2:
				item = ITEMTYPES.BUBBLESHIELD
		$Item.frame = item + 2
	
	if !isActive:
		return false
	# create explosion
	var explosion = Explosion.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	# deactivate
	isActive = false
	physics = false
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
			var prev_rings = playerTouch.rings
			playerTouch.rings += 10
			playerTouch.totalRings += 10
			if Global.hud: #If the HUD Exists
				if (Global.emeralds == 127 and 
				(prev_rings < 50 and playerTouch.rings > 49) and 
				!playerTouch.isSuper):
					Global.hud.iconAnim.play("Super")
			$SFX/Ring.play()
		ITEMTYPES.SPEED_SHOES: # Speed Shoes
			if !playerTouch.get("isSuper"):
				playerTouch.shoeTime = 20
				playerTouch.switch_physics()
				Global.currentTheme = Global.THEME.SPEED
				Global.playMusic(Global.themes[Global.currentTheme])
		ITEMTYPES.INVINCIBILITY: # Invincibility
			if !playerTouch.get("isSuper"):
				playerTouch.supTime = 20
				playerTouch.shieldSprite.visible = false # turn off barrier for stars
				playerTouch.get_node("InvincibilityBarrier").visible = true
				Global.currentTheme = Global.THEME.INVINCIBLE
				Global.playMusic(Global.themes[Global.currentTheme])
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
		ITEMTYPES.TELEPORT:
			pass
		ITEMTYPES.BOOST:
			pass
		ITEMTYPES.EGGMAN:
			playerTouch.hit_player(global_position,0,6)
		ITEMTYPES.QMARK:
			pass
		ITEMTYPES.LIFEP1: # 1up
			Global.life.stop()
			Global.life.play()
			Global.lives += 1
			if Global.hud and !Global.two_player_mode:
				Global.hud.coins += 1
			Global.music.volume_db = -100
		ITEMTYPES.LIFEP2: #2-Player 1up
			Global.life.stop()
			Global.life.play()
			Global.livesP2 +=1
			Global.music.volume_db = -100


func _physics_process(delta):
	if !Engine.is_editor_hint():
		# if physics are on make em fall
		if physics:
			var collide = move_and_collide(Vector2(velocity.x,yspeed)*delta)
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
			if body.movement.y >= 0 and body.movement.x != 0 and (body.playerControl == 1 or Global.two_player_mode):
				playerTouch = body
				destroy()
			else:
				# Stop horizontal movement
				body.movement.x = 0
		# check if player is not an ai or spindashing
		# if they are then destroy
		
		
		if (body.playerControl == 1 or Global.two_player_mode) and (
		body.currentState != body.STATES.SPINDASH):
			print(body.animator.current_animation)
			if  (body.animator.current_animation == "dropDash"):
				body.movement.y = 8*60
			else:
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
