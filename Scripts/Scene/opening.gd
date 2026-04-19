extends Node2D


@export var music: AudioStream = preload("res://Audio/Soundtrack/s2br_2PResults.ogg")
@export var eggman_music: AudioStream = preload("res://Audio/Soundtrack/s2br_Boss.ogg")
var title_screen: String = "res://Scene/Presentation/Title.tscn"
var explosion: PackedScene = preload("res://Entities/Misc/GenericParticle.tscn")

var endScene: bool = false

func _ready() -> void:
	SoundDriver.playMusic(music)
#	Global.music.stream = music
#	Global.music.play()

func _input(event: InputEvent) -> void:
	if !endScene:
		# finish character select if start is pressed
		if (event.is_action_pressed("ui_pause")):
			await returnTitleScreen()
		elif event is InputEventMouseButton and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				await returnTitleScreen()

func returnTitleScreen() -> void:
	if !endScene:
		endScene = true
		await Main.change_scene(title_screen)

func spawnExplosion(pos: Vector2) -> void:
	# create explosion
	var Explosion: Node2D = explosion.instantiate()
	get_parent().add_child(Explosion)
	Explosion.global_position = pos
	Explosion.play("BossExplosion")


func _on_timer_timeout() -> void:
	SoundDriver.playMusic(eggman_music)
