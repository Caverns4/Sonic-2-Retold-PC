extends Node

## Time to wait before moving on automaticaly, or 0 to disable the timer.
@export var time: float = 0.0 
@export var music: AudioStream = preload("res://Audio/Soundtrack/s2br_2PResults.ogg")
@export var returnScene: PackedScene = load("res://Scene/Presentation/Title.tscn")

var endScene = false
## The created Timer Node, if applicable.
var timer: Timer = Timer.new()

func _ready():
	if music:
		Global.music.stream = music
		Global.music.play()
	if time > 0:
		timer = Timer.new()
		add_child(timer)
		timer.wait_time = time
		timer.one_shot = true
		timer.timeout.connect(_is_timer_expired)
		timer.start()

func _input(event):
	if !endScene:
		# finish character select if start is pressed
		if (event.is_action_pressed("gm_pause")
		or event.is_action_pressed("gm_action")
		or event.is_action_pressed("gm_action2")
		or event.is_action_pressed("gm_action3")) and !endScene:
			endScene = true
			Global.main.change_scene_to_file(returnScene,"FadeOut","FadeOut",1)

func _is_timer_expired():
	if !endScene:
		endScene = true
		Global.main.change_scene_to_file(returnScene,"FadeOut","FadeOut",1)
