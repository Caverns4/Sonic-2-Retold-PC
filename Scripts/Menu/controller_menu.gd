class_name ControllerMenu
extends CanvasLayer

## The name of each assignable action in order.
const ACTION_NAMES: Array[String] = [
	"ui_up",
	"ui_down",
	"ui_left",
	"ui_right",
	"ui_accept",
	"ui_select",
	"ui_cancel",
	"ui_super",
	"ui_pause"
]
## String to append for two-player action checks.
const PLAYER2STR: String = "_P2"

signal menu_exit()

## The current Player controller being modified
var player_index: int = 0
## Whether the game was considered paused or not previously.
var saved_state: bool = false

@onready var player_1_button: Button = $PlayerPanel/Player1
@onready var player_2_button: Button = $PlayerPanel/Player2
@onready var button_container: Panel = $ButtonPanels
@onready var confirm_button: Button = $ConfirmOrReset/Confirm
@onready var defaults_button: Button = $ConfirmOrReset/Defaults
@onready var warningtext: Label = $WarningText

func _ready() -> void:
	# get defaults before loading inputs
	for i: String in ACTION_NAMES:
		default_map.append(InputMap.action_get_events(i))
		default_map.append(InputMap.action_get_events(i+PLAYER2STR))
	load_custom_controls()
	
	await get_tree().process_frame
	confirm_button.disabled = true
	defaults_button.disabled = true
	load_button_strings()


func _on_visibility_changed() -> void:
	if is_node_ready() and visible:
		saved_state = get_tree().paused
		get_tree().paused = true
		player_1_button.grab_focus()
	

func load_button_strings() -> void:
	#var add: String = PLAYER2STR if player_index > 0 else ""
	for i in button_container.get_children(false):
		if i is Button:
			var butt: Button = i
			butt.player_index = player_index
			butt.update_text()
	var is_invalid: bool = check_redundant_inputs(player_index)
	update_confirm_buttons(is_invalid)


func check_redundant_inputs(pl: int) -> bool:
	var counted: Array[InputEvent] = [] 
	var action_names: Array[String] = ACTION_NAMES
	
	if pl > 0:
		for i: String in action_names:
			i += PLAYER2STR
	
	for event_name: String in action_names:
		if InputMap.action_get_events(event_name).size() == 0:
			warningtext.text = "WARNING: " + event_name + "appears unassigned."
			return true
		for event_index in InputMap.action_get_events(event_name):
			if counted.has(event_index):
				warningtext.text = "WARNING: " + event_name + "contains a redundant action, " + str(event_index)
				return true
			else:
				counted.append(event_index)
	warningtext.text = ""
	return false

func update_confirm_buttons(state: bool) -> void:
	confirm_button.disabled = state
	defaults_button.disabled = state

func set_unchecked_buttons(exception: Button, state: bool) -> void:
	for child in get_children(true):
		if child is Button and child != exception:
			var butt: Button = child
			if state:
				butt.disabled = true
				butt.focus_mode = Control.FOCUS_NONE
			else:
				butt.disabled = false
				butt.focus_mode = Control.FOCUS_ALL


var default_map: Array = []

func _on_defaults_pressed() -> void:
	set_default_controls()
	save_control_data()
	load_button_strings()
	#visible = false
	#get_tree().paused = saved_state
	#menu_exit.emit()

func set_default_controls() -> void:
	var index: int = 0
	for action: String in ACTION_NAMES:
		InputMap.action_erase_events(action)
		InputMap.action_erase_events(action+PLAYER2STR)
		for i: InputEvent in default_map[index]:
			InputMap.action_add_event(action,i)
		index += 1
		for i: InputEvent in default_map[index]:
			InputMap.action_add_event(action+PLAYER2STR,i)
		index += 1

func _on_confirm_pressed() -> void:
	save_control_data()
	visible = false
	get_tree().paused = saved_state
	menu_exit.emit()

# Save configuration data
func save_control_data() -> void:
	var file: ConfigFile = ConfigFile.new()
	# save inputs
	for action: String in ACTION_NAMES:
		file.set_value("controls",action,InputMap.action_get_events(action))
		file.set_value("controls",action+PLAYER2STR,InputMap.action_get_events(action+PLAYER2STR))
	# save config and close
	file.save("user://Config.cfg")

func load_custom_controls() -> void:
	var file: ConfigFile = ConfigFile.new()
	var err: Error = file.load("user://Config.cfg")
	if err != OK:
		return
	## Inject the controls from the file
	for action: String in ACTION_NAMES:
		if (file.has_section_key("controls",action)):
			InputMap.action_erase_events(action)
			for i: InputEvent in file.get_value("controls",action):
				InputMap.action_add_event(action,i)
		if (file.has_section_key("controls",action+PLAYER2STR)):
			InputMap.action_erase_events(action+PLAYER2STR)
			for i: InputEvent in file.get_value("controls",action+PLAYER2STR):
				InputMap.action_add_event(action+PLAYER2STR,i)


func _on_player_1_pressed() -> void:
	player_index = 0
	load_button_strings()


func _on_player_2_pressed() -> void:
	player_index = 1
	load_button_strings()
