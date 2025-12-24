extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")

var title_scene: String = "res://Scene/Presentation/Title.tscn"
var zone_loader: String = "res://Scene/Presentation/ZoneLoader.tscn"

var sfx_Select = preload("res://Audio/SFX/Gimmicks/s2br_Switch.wav")
var sfx_Confirm = preload("res://Audio/SFX/Objects/s2br_Checkpoint.wav")

enum MENU_STATE{CHARACTER_SELECT,DECIDED}
var state = 0
var timer = 0.0

var current_selection: int = 0
var selected_save_slot: Node2D = null

#Input storage
var inputCue: Vector2 = Vector2.ZERO # Current inputs (this frame)
var lastInput: Vector2 = Vector2.ZERO # Last saved direction input.
var inputCueP2: Vector2 = Vector2.ZERO
var lastInputP2: Vector2 = Vector2.ZERO

# button delay
const BUTTON_TIME = 0.3 # Time to wait before counting repeat inputs.
var stepTimer: float = 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundDriver.music.stream = music
	SoundDriver.music.play()
	
	var pos: int = 8
	var index = 0
	for i:DataSelectPanel in %SaveFileContainer.get_children():
		i.global_position.x = pos
		pos+=104
		i.save_game_id = index
		index+=1
	
	highlight_selected_child(current_selection)


func _physics_process(delta: float) -> void:
	timer+=delta
	#Recieve input
	_unhandledInput(Input)
	if state == MENU_STATE.CHARACTER_SELECT:
		updateCharacterSelection()
	
	var target_pos = clampf(
		%SaveFileContainer.get_child(current_selection).global_position.x+56,
		160,
		(%SaveFileContainer.get_child_count()-1) * 104
	)
	
	$Camera2D.global_position.x = move_toward(
		$Camera2D.global_position.x,
		target_pos,
		delta * 512
	)
	#Remember input
	lastInput = inputCue
	

func _unhandledInput(_event):
	#Player 1
	inputCue = Input.get_vector("gm_left","gm_right","gm_up","gm_down")
	inputCue.x = round(inputCue.x)
	inputCue.y = round(inputCue.y)
	#PLayer 2
	inputCueP2 = Input.get_vector("gm_left_P2","gm_right_P2","gm_up_P2","gm_down_P2")
	inputCueP2.x = round(inputCueP2.x)
	inputCueP2.y = round(inputCueP2.y)

func updateCharacterSelection():
	if inputCue.x !=0 and inputCue.x != lastInput.x:
		current_selection += round(inputCue.x)
		current_selection = wrapi(current_selection,0,%SaveFileContainer.get_child_count())
		highlight_selected_child(current_selection)
		SoundDriver.play_sound2(sfx_Select)
		
	if inputCue.y !=0 and inputCue.y != lastInput.y:
		var change: bool = selected_save_slot.update_menu_item(inputCue.y)
		if change:
			$Switch.play()
	
	if (Input.is_action_just_pressed("gm_action") or
	Input.is_action_just_pressed("gm_pause")):
		UseSelectedItem()
	
	if (
	(Input.is_action_just_pressed("gm_action2")) or
	(Input.is_action_just_pressed("gm_action2_P2"))
	):
		state = MENU_STATE.DECIDED
		Main.change_scene(title_scene)

func highlight_selected_child(current: int):
	for i in %SaveFileContainer.get_child_count():
		%SaveFileContainer.get_child(i).update_selection_state(i == current)
		if i == current:
			selected_save_slot = %SaveFileContainer.get_child(i)

func UseSelectedItem():
	var fadeout: bool = selected_save_slot.use()
	if fadeout:
		SoundDriver.play_sound2(sfx_Confirm)
		Main.change_scene(zone_loader)
		state = MENU_STATE.DECIDED
	
