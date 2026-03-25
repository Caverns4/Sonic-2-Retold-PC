@tool
extends Area2D

@export var start_frame: int = 0
@export var speed: float = 1.0

@onready var log_sprite: Sprite2D = $Sprite2D

@export_enum("Normal", "Fire", "Elec", "Water") var damageType: int = 0
var playerHit: Array[Player2D] = []

func _process(_delta:float)-> void:
	if Engine.is_editor_hint():
		log_sprite.frame = start_frame
		return
	log_sprite.frame = wrapi(floori( Global.globalTimer * speed)+start_frame, 0, 8)
	# do hit if player array isn't empty
	if (playerHit.size() > 0):
		for i in playerHit:
			if (i.has_method("hit_player")):
				i.hit_player(global_position,damageType)

func _on_body_entered(body: Player2D) -> void:
	if (!playerHit.has(body)):
		playerHit.append(body)


func _on_body_exited(body: Player2D) -> void:
	if (playerHit.has(body)):
		playerHit.erase(body)

func _on_sprite_2d_frame_changed() -> void:
	monitoring = bool(log_sprite.frame == 0)
	monitorable = bool(log_sprite.frame == 0)
	#log_sprite.z_index = 10 if log_sprite.frame < 4 else 1
