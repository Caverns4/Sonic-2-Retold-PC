extends Node

## Time to wait before moving on automaticaly, or 0 to disable the timer.
@export var time: float = 0.0 
@export var music: AudioStream = preload("res://Audio/Soundtrack/s2br_2PResults.ogg")
@export var returnScene: String = "res://Scene/Presentation/Title.tscn"

var endScene: bool = false
## The created Timer Node, if applicable.
var timer: Timer = Timer.new()

func _ready() -> void:
	if music:
		SoundDriver.music.stream = music
		SoundDriver.music.play()
	if time > 0:
		timer = Timer.new()
		add_child(timer)
		timer.wait_time = time
		timer.one_shot = true
		timer.timeout.connect(_is_timer_expired)
		timer.start()

func _input(event: InputEvent) -> void:
	if !endScene:
		# finish character select if start is pressed
		if (event.is_action_pressed("ui_pause")
		or event.is_action_pressed("ui_accept")
		or event.is_action_pressed("ui_select")
		or event.is_action_pressed("ui_cancel")) and !endScene:
			endScene = true
			await Main.change_scene(returnScene)

func _is_timer_expired() -> void:
	if !endScene:
		endScene = true
		await Main.change_scene(returnScene)
