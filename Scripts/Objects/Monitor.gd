@tool
extends CharacterBody2D

enum STATE{NORMAL,PHYSICS,BROKEN}
var state: STATE = STATE.NORMAL

var grv: float = 0.21875
var yspeed: float = 0
var playerTouch: Player2D = null

## The Item Type contained by default.
@export_enum("Ring", "Speed Shoes", "Invincibility", "Shield",
"Elec Shield", "Fire Shield", "Bubble Shield", "Super",
"Teleport", "Boost","Eggman","?", "Extra Life", "Tails Life") var item: int = 0

## The shield this monitor will give the player if they have a shield already.
@export_enum("None", "Elec Shield",
"Fire Shield", "Bubble Shield") var shieldAffinity: int = 0

enum ITEMTYPES{RING,SPEED_SHOES,INVINCIBILITY, SHIELD, ELECSHIELD, FIRESHIELD,
BUBBLESHIELD,SUPER,TELEPORT,BOOST,EGGMAN,QMARK,LIFEP1,LIFEP2}

var twoPlayerItems: Array[ITEMTYPES] = [
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

var Explosion: PackedScene = preload("res://Entities/Misc/BadnickSmoke.tscn")

signal destroyed

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if Global.object_table.has(get_path()):
		disable_collision()
		$Animator.play("Broken")
	if Global.two_player_mode:
		item = ITEMTYPES.QMARK
	# set frame
	$Item.frame = item+2
	# Life Icon (life icons are a special case)
	if item == ITEMTYPES.LIFEP1 and !Engine.is_editor_hint():
		if Global.livesMode:
			$Item.frame = item+2 + Global.PlayerChar1
	if item == ITEMTYPES.LIFEP2 and !Engine.is_editor_hint():
		var nextFrame: int = item+1 + Global.PlayerChar2
		$Item.frame = nextFrame
	destroyed.connect(_on_destroyed)

func _process(_delta: float) -> void:
	# update for editor
	if Engine.is_editor_hint():
		$Item.frame = item+2
		if item == ITEMTYPES.LIFEP1:
			$Item.frame = item+3
		if item == ITEMTYPES.LIFEP2:
			$Item.frame = item+3

func FrameUpdate() -> void:
	$Item.frame = item+2

func destroy() -> void:
	# deactivate
	destroyed.emit()
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


	if item == ITEMTYPES.SHIELD and !Global.two_player_mode and playerTouch.shield > 0:
		if shieldAffinity == 1:
			item = ITEMTYPES.ELECSHIELD
		if shieldAffinity == 2:
			item = ITEMTYPES.FIRESHIELD
		if shieldAffinity == 3:
			item = ITEMTYPES.BUBBLESHIELD
		else:
			var rand: int = randi_range(0,2)
			if rand == 0:
				item = ITEMTYPES.ELECSHIELD
			elif rand == 1:
				item = ITEMTYPES.FIRESHIELD
			elif rand == 2:
				item = ITEMTYPES.BUBBLESHIELD
		$Item.frame = item + 2

	# create explosion
	state = STATE.BROKEN
	var explosion: Node2D = Explosion.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
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
			var prev_rings: int = playerTouch.rings
			playerTouch.rings += 10
			if Global.hud: #If the HUD Exists
				if (Global.emeralds == 127 and 
				(prev_rings < 50 and playerTouch.rings > 49) and 
				!playerTouch.is_super):
					Global.hud.iconAnim.play("Super")
			$SFX/Ring.play()
		ITEMTYPES.SPEED_SHOES: # Speed Shoes
			if !playerTouch.get("is_super"):
				playerTouch.shoe_time = 20
				playerTouch.switch_physics()
				SoundDriver.playMusic(SoundDriver.themes[SoundDriver.THEME.SPEED])
		ITEMTYPES.INVINCIBILITY: # Invincibility
			if !playerTouch.get("is_super"):
				playerTouch.super_time = 20
				playerTouch.shieldSprite.visible = false # turn off barrier for stars
				playerTouch.get_node("InvincibilityBarrier").visible = true
				SoundDriver.playMusic(SoundDriver.themes[SoundDriver.THEME.INVINCIBLE])
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
			if !playerTouch.get("is_super"):
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
			Global.lives += 1
			if Global.hud and !Global.two_player_mode:
				Global.hud.coins += 1
			await SoundDriver.playExtraLifeMusic()
		ITEMTYPES.LIFEP2: #2-Player 1up
			Global.livesP2 +=1
			await SoundDriver.playExtraLifeMusic()



func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		# if physics are on make it fall
		if state == STATE.PHYSICS:
			var collide: KinematicCollision2D = move_and_collide(Vector2(velocity.x,yspeed)*delta)
			yspeed += grv/GlobalFunctions.div_by_delta(delta)
			if collide and yspeed > 0:
				yspeed = 0.0

# physics collision check, see physics object
func physics_collision(body: Player2D, hitVector: Vector2) -> void:
	if state == STATE.BROKEN: return
	# Monitor head bouncing
	if hitVector.y < 0:
		yspeed = -1.5*60
		state = STATE.PHYSICS
		if body.movement.y < 0:
			body.movement.y *= -1
	# check that player has the rolling layer bit set
	elif body.is_attacking():
		# Bounce from below
		if hitVector.x != 0:
			# check conditions for interaction (and the player is the first player)
			if body.movement.y >= 0 and body.movement.x != 0 and (
				body.playerControl == 1 or Global.two_player_mode):
					playerTouch = body
					disable_collision()
					await destroy()
					return
			else:
				# Stop horizontal movement
				body.movement.x = 0
		# check if player is actually "playable"
		if (body.playerControl == 1 or Global.two_player_mode) and (
		body.currentState != body.STATES.SPINDASH):
			if (body.animator.current_animation == "drop"):
				body.movement.y = 8*60
				body.ground = false
			elif !body.ground:
				body.movement.y = -max(120,abs(body.movement.y))
				body.ground = false
			playerTouch = body
			disable_collision()
			await destroy()
			return
		else:
			body.ground = true
			body.movement.y = 0

# insta shield should break instantly
func _on_InstaArea_area_entered(area: Area2D) -> void:
	if area.get("parent") != null:
		area.parent.movement.y *= -1
		playerTouch = area.parent
		disable_collision()
		await destroy()

func _on_destroyed() -> void:
	Global.object_table.append(get_path())

func disable_collision() -> void:
	collision_layer = 0
	collision_mask = 0
	$CollisionShape2D.disabled = true
	$InstaArea.monitorable = false
	$InstaArea.monitoring = false
	state = STATE.PHYSICS
	yspeed = 0.0
