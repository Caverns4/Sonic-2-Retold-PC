class_name EnemyProjectileBase extends CharacterBody2D

@export_enum("Normal", "Fire", "Elec", "Water") var damageType: int = 0
@export var canBeReflect: bool = true
var playerHit: Array[Player2D] = []


var reflected: bool = false
var reflectSpeed: float = 400
var forceReflect: bool

func _ready()-> void:
	#$projectile.frame = 0
	pass

func _process(delta: float)-> void:
	if playerHit.size() > 0:
		for i in playerHit:
			if (i.has_method("hit_player")) and !reflected:
				# if player shield is an elemental one then reflect
				if (i.shield > 1 or forceReflect or i.reflective) and canBeReflect:
					velocity = i.global_position.direction_to(global_position)*reflectSpeed
					reflected = true
				else:
					i.hit_player(global_position,damageType)
	# shift
	translate(velocity*delta)

func _on_body_entered(body: Player2D)-> void:
	if !playerHit.has(body):
		playerHit.append(body)

func _on_body_exited(body: Player2D)-> void:
	if playerHit.has(body):
		playerHit.erase(body)

func _on_DamageArea_area_entered(area: Area2D)-> void:
	if area.get("parent") != null and area.is_attacking():
		if !playerHit.has(area.parent):
			playerHit.append(area.parent)
			forceReflect = true



func _on_VisibilityNotifier2D_screen_exited()-> void:
	queue_free()
