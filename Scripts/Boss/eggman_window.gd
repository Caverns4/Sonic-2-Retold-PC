extends AnimatedSprite2D

@export_node_path var silver_sonic: NodePath

func _ready() -> void:
	var boss: BossBase = get_node_or_null(silver_sonic)
	if boss:
		boss.boss_started.connect(appear)
		boss.hit_player.connect(laugh)
		boss.got_hit.connect(cry)
		boss.defeated.connect(retreat)

func appear():
	play("Appear")

func laugh():
	play("Laugh")

func cry():
	play("Hurt")

func retreat():
	play("Disappear")


func _on_animation_finished() -> void:
	if animation != "Disappear":
		play("idle")
