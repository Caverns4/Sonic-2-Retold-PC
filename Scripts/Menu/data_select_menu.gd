extends Control

@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")

var title_scene: String = "res://Scene/Presentation/Title.tscn"
var zone_loader: String = "res://Scene/Presentation/ZoneLoader.tscn"

var sfx_Select = preload("res://Audio/SFX/Gimmicks/s2br_Switch.wav")
var sfx_Confirm = preload("res://Audio/SFX/Objects/s2br_Checkpoint.wav")

enum MENU_STATE{SAVE_SELECT,DELETE_FILE,DECIDED}
var state = 0
var timer = 0.0

var current_selection: int = 0
var selected_save_slot: Node2D = null
var delete_slot: DataSelectPanel = null

#Input storage
var inputCue: Vector2 = Vector2.ZERO # Current inputs (this frame)
var lastInput: Vector2 = Vector2.ZERO # Last saved direction input.
var inputCueP2: Vector2 = Vector2.ZERO
var lastInputP2: Vector2 = Vector2.ZERO

# button delay
const BUTTON_TIME = 0.3 # Time to wait before counting repeat inputs.
var stepTimer: float = 0.3

@onready var title_bar: RichTextLabel = $CanvasTop/Control/GameModeText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundDriver.music.stream = music
	SoundDriver.music.play()
	
	var index: int = 0
	for child:DataSelectPanel in %SaveFileContainer.get_children():
		child.save_game_id = index
		child.press.connect(use)
		index += 1
	
	%SaveFileContainer.get_child(0).grab_focus()


func use(save_file_id: int):
	print(save_file_id)

func UseSelectedItem():
	var fadeout: bool = selected_save_slot.use()
	if fadeout:
		SoundDriver.play_sound2(sfx_Confirm)
		Main.change_scene(zone_loader)
		state = MENU_STATE.DECIDED
