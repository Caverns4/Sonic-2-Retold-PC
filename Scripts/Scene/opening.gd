extends Node2D


@export var music = preload("res://Audio/Soundtrack/s2br_2PResults.ogg")
var returnScene = load("res://Scene/Presentation/Title.tscn")
var explosion = preload("res://Entities/Misc/GenericParticle.tscn")

var endScene = false

#func _ready():
#	Global.music.stream = music
#	Global.music.play()

func _input(event):
	if !endScene:
		# finish character select if start is pressed
		if (event.is_action_pressed("gm_pause")) and !endScene:
			returnTitleScreen()

func returnTitleScreen():
	if !endScene:
		endScene = true
		Global.main.change_scene_to_file(returnScene,"FadeOut","FadeOut",1)

func spawnExplosion(pos):
	# create explosion
	var Explosion = explosion.instantiate()
	get_parent().add_child(Explosion)
	Explosion.global_position = pos
	Explosion.play("BossExplosion")
	
