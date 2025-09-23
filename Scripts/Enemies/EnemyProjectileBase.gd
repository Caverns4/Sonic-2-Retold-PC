class_name EnemyProjectileBase extends CharacterBody2D

@export_enum("Normal", "Fire", "Elec", "Water") var damageType = 0
@export var canBeReflect = true
var playerHit = []


var reflected = false
var reflectSpeed = 400
var forceReflect

func _ready():
	#$projectile.frame = 0
	pass

func _process(delta):
	if playerHit.size() > 0:
		for i in playerHit:
			if (i.has_method("hit_player")) and !reflected:
				# if player shield is an elemental one then reflect
				if (i.shield > 1 or i.curled or forceReflect or i.reflective) and canBeReflect:
					velocity = i.global_position.direction_to(global_position)*reflectSpeed
					reflected = true
				else:
					i.hit_player(global_position,damageType)
	# shift
	translate(velocity*delta)

func _on_body_entered(body):
	if !playerHit.has(body):
		playerHit.append(body)

func _on_body_exited(body):
	if playerHit.has(body):
		playerHit.erase(body)

func _on_DamageArea_area_entered(area):
	if area.get("parent") != null and area.get_collision_layer_value(20):
		if !playerHit.has(area.parent):
			forceReflect = true
			playerHit.append(area.parent)



func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
