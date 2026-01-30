class_name EnemyBase extends CharacterBody2D

@export_enum("Normal", "Fire", "Elec", "Water") var damageType = 0
var playerHit = []

var Explosion = preload("res://Entities/Misc/BadnickSmoke.tscn")
var Animal = preload("res://Entities/Misc/Animal.tscn")
var forceDamage: bool = false
var defaultMovement: bool = true

signal destroyed

func  _ready() -> void:
	if Global.object_table.has(get_path()):
		queue_free()
	if get_node_or_null('VisibleOnScreenEnabler2D') != null:
		$VisibleOnScreenEnabler2D.visible = true
	destroyed.connect(On_destroyed)

func _process(delta):
	# checks if player hit has players inside
	if (playerHit.size() > 0):
		# loop through players as i
		for i in playerHit:
			# check if damage entity is on or supertime is bigger then 0
			if (i.get_collision_layer_value(20) or i.super_time > 0 or forceDamage):
				# check player is not on floor
				var skipBounce = (i.animator.current_animation == "drop")
				if !i.ground and !(skipBounce):
					if i.movement.y > 0:
						# Bounce high upward
						i.movement.y = -i.movement.y
					else:
						# Bounce slightly down
						i.movement.y += 120
					
					#Original badnik bounce behaviour. Jankier but more accurate.
					#if i.movement.y > 0 and i.global_position.y < global_position.y:
					#	# Bounce high upward
					#	i.movement.y = -i.movement.y
					#elif i.movement.y <= 0:
					#	# Bounce slightly down
					#	i.movement.y += 200
					#else:
					#	# Bounce slightly up
					#	i.movement.y = min (i.movement.y,0)
					#	i.movement.y -= 100
					
					if i.shield == i.SHIELDS.BUBBLE:
							i.emit_enemy_bounce()
				# destroy
				var playerID = Global.players.find(i)
				Global.add_score(global_position,
				Global.SCORE_COMBO[min(Global.SCORE_COMBO.size()-1,i.enemyCounter)],
				playerID)
				i.enemyCounter += 1
				destroy()
				# cut the script short
				return false
			# if destroying the enemy fails and hit player exists then hit player
			if (i.has_method("hit_player")):
				i.hit_player(global_position,damageType)
	# move
	if defaultMovement:
		translate(velocity*delta)

func _on_body_entered(body):
	# add to player list
	if (!playerHit.has(body)):
		playerHit.append(body)


func _on_body_exited(body):
	# remove from player list
	if (playerHit.has(body)):
		playerHit.erase(body)

func _on_DamageArea_area_entered(area):
	# damage checking
	if area.get("parent") != null and area.get_collision_layer_value(20):
		if !playerHit.has(area.parent):
			forceDamage = true
			playerHit.append(area.parent)

func destroy():
	emit_signal("destroyed")
	# create explosion
	var explosion = Explosion.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.z_index = z_index
	# create animal
	var animal = Animal.instantiate()
	animal.animal = Global.animals[round(randf())]
	get_parent().add_child(animal)
	animal.global_position = global_position
	Global.object_table.append(get_path())
	# free node
	queue_free()

func On_destroyed():
	pass
