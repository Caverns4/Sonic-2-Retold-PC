extends CanvasLayer

const joyAxisNameList = [
"L Stick X",
"L Stick Y",
"R Stick X",
"R Stick Y",
"Generic 4",
"Generic 5",
"LTrigger",
"RTrigger",
"Generic 8",
"Generic 9",
"Axis max",
]

var current_player: int = 0
var current_bind: int = -1

## If true, we are in automatic assignment mode, ignore other inputs.
var sequence_mode: bool = false
## If the player has control at the moment. Used to prevent accidental swapping.
var recieve_input: bool = true

@onready var buttons_panel = $ButtonPanels

@onready var buttons_list: Array[Button] = [
	$ButtonPanels/Up,
	$ButtonPanels/Down,
	$ButtonPanels/Left,
	$ButtonPanels/Right,
	$ButtonPanels/Action,
	$ButtonPanels/Action2,
	$ButtonPanels/Action3,
	$ButtonPanels/Super,
	$ButtonPanels/Pause
]

@onready var confirm_list: Array[Button] = [
	$ConfirmOrReset/Confirm,
	$ConfirmOrReset/Defaults
]

var player_inputs: Array[String] = [
	"gm_up",
	"gm_down",
	"gm_left",
	"gm_right",
	"gm_action",
	"gm_action2",
	"gm_action3",
	"gm_super",
	"gm_pause"
]

var default_map = []

signal assign_button_pressed()
signal menu_exit()

@onready var map_label: Label = $CurrentMapList

func _ready() -> void:
	load_data()
	# get defaults before loading inputs
	for i in InputMap.get_actions():
		default_map.append(InputMap.action_get_events(i))
	for i in $ButtonPanels.get_child_count():
		if $ButtonPanels.get_child(i) is Button:
			var btn =  $ButtonPanels.get_child(i)
			btn.pressed.connect(keybind_button_pressed.bind(btn))
	_update_button_text()

func _update_button_text():
	for i in $ButtonPanels.get_child_count():
		if $ButtonPanels.get_child(i) is Button:
			var btn =  $ButtonPanels.get_child(i)
			
			var player_id = ""
			if current_player > 0:
				player_id = "_P2"
			var j = player_inputs[i] + player_id
			if j is InputEventJoypadButton:
				buttons_list[current_bind].text = j.as_text().right(3).trim_suffix(")")
				buttons_list[current_bind].text = "button " + buttons_list[current_bind].text
			elif j is InputEventJoypadMotion:
				buttons_list[current_bind].text = joyAxisNameList[j.axis]+str(int(j.axis_value))
			btn.text = InputMap.get_action_description(j)
	

func _input(event: InputEvent) -> void:
	if visible and current_bind > -1 and recieve_input:
		var player_id = ""
		if current_player > 0:
			player_id = "_P2"
		buttons_list[current_bind].grab_focus()
		
		if Input.is_action_just_pressed("ui_clear_action"):
			InputMap.action_erase_events(player_inputs[current_bind]+player_id)
			map_label.text = "assignment erased, try again"
		elif ((event is InputEventKey and event.is_pressed()) or 
		event is InputEventJoypadButton or 
		(event is InputEventJoypadMotion and abs(event.axis_value) >= 1.0)):
			InputMap.action_add_event(player_inputs[current_bind]+player_id,event)
			buttons_list[current_bind].text = event.as_text().right(10)
			if event is InputEventJoypadButton:
				buttons_list[current_bind].text = event.as_text().right(3).trim_suffix(")")
				buttons_list[current_bind].text = "button " + buttons_list[current_bind].text
			elif event is InputEventJoypadMotion:
				buttons_list[current_bind].text = joyAxisNameList[event.axis]+str(int(event.axis_value))
				
			if !sequence_mode:
				current_bind = -1
				$ButtonPanels.process_mode = Node.PROCESS_MODE_INHERIT
			map_label.text = "assignment success"
			recieve_input = false
			await get_tree().create_timer(0.5).timeout
			assign_button_pressed.emit()
			recieve_input = true


func _on_player_1_pressed() -> void:
	current_player = 0
	_update_button_text()
	bind_each_input()


func _on_player_2_pressed() -> void:
	current_player = 1
	_update_button_text()
	bind_each_input()

func keybind_button_pressed(emitter: Button):
	if !sequence_mode and recieve_input:
		var index = buttons_list.find(emitter)
		current_bind = index
		map_label.text = "press command for " + player_inputs[current_bind]
		$ButtonPanels.process_mode = Node.PROCESS_MODE_DISABLED
	

func bind_each_input():
	$ButtonPanels.process_mode = Node.PROCESS_MODE_DISABLED
	sequence_mode = true
	$PlayerPanel/Player1.disabled = true
	$PlayerPanel/Player2.disabled = true
	$ConfirmOrReset/Confirm.disabled = true
	$ConfirmOrReset/Defaults.disabled = true
	for button: int in buttons_panel.get_child_count(false):
		buttons_list[button].grab_focus()
		current_bind = button
		map_label.text = "press command for " + player_inputs[current_bind]
		await assign_button_pressed
	map_label.text = "assignment success"
	current_bind = -1
	sequence_mode = false
	$PlayerPanel/Player1.disabled = false
	$PlayerPanel/Player2.disabled = false
	$ConfirmOrReset/Confirm.disabled = false
	$ConfirmOrReset/Defaults.disabled = false 
	$ConfirmOrReset/Confirm.grab_focus()
	$ButtonPanels.process_mode = Node.PROCESS_MODE_INHERIT


func _on_confirm_pressed() -> void:
	if current_bind < 0:
		save_control_data()
		visible = false
		get_tree().paused = false
		menu_exit.emit()


func _on_defaults_pressed() -> void:
	if current_bind < 0:
		var getActions = InputMap.get_actions()
		for i in getActions.size():
			InputMap.action_erase_events(getActions[i])
			for j in default_map[i]:
				InputMap.action_add_event(getActions[i],j)
		
		visible = false
		get_tree().paused = visible


func _on_visibility_changed() -> void:
	if is_node_ready() and visible:
		$PlayerPanel/Player1.grab_focus()
		recieve_input = true
		$ButtonPanels.process_mode = Node.PROCESS_MODE_INHERIT


# Save and load routines directly copied from the original
# save configuration data
func save_control_data():
	var file = ConfigFile.new()
	# save inputs
	var actionCount = 0
	for i in InputMap.get_actions(): # input names
		actionCount = 0
		for j in InputMap.action_get_events(i): # the keys
			# key storage is complex, here we keep a record of keys, gamepad buttons and gamepad axis's
			# prefix keys: K = Key, B = joypad Button, A = Axis, V = AxisValue
			if j is InputEventKey:
				file.set_value("controls","K"+str(actionCount)+i,j.get_keycode_with_modifiers())
			elif j is InputEventJoypadButton:
				file.set_value("controls","B"+str(actionCount)+i,j.button_index)
				file.set_value("controls","B"+str(actionCount)+i+"Device",j.device)
			elif j is InputEventJoypadMotion:
				file.set_value("controls","A"+str(actionCount)+i,j.axis)
				file.set_value("controls","V"+str(actionCount)+i,j.axis_value)
				file.set_value("controls","A"+str(actionCount)+i+"Device",j.device)
			# incease counters (prevents conflicts)
			actionCount += 1
	# save config and close
	file.save("user://Config.cfg")

# load config data
func load_data():
	var file = ConfigFile.new()
	var err = file.load("user://Config.cfg")
	if err != OK:
		return false # Return false as an error
	
	# load inputs
	var actionCount = 0
	for i in InputMap.get_actions(): # loop through input names
		# prefix keys: K = Key, B = joypad Button, A = Axis, V = AxisValue
		
		# check for any inputs, if any are found then remove binding
		if (file.has_section_key("controls","K0"+i) or 
		file.has_section_key("controls","B0"+i) or
		file.has_section_key("controls","A0"+i) or 
		file.has_section_key("controls","V0"+i)):
			# clear input
			InputMap.action_erase_events(i)
		# check prefixes
		while (file.has_section_key("controls","K"+str(actionCount)+i) or 
		file.has_section_key("controls","B"+str(actionCount)+i) or
		file.has_section_key("controls","A"+str(actionCount)+i) or 
		file.has_section_key("controls","V"+str(actionCount)+i)):
			
			# keyboard check
			if (file.has_section_key("controls","K"+str(actionCount)+i)):
				# define new key
				var getInput = InputEventKey.new()
				# grab keycode
				getInput.keycode = file.get_value("controls","K"+str(actionCount)+i)
				# set new input
				InputMap.action_add_event(i,getInput)
			# joypad button check
			if (file.has_section_key("controls","B"+str(actionCount)+i)):
				# define new key
				var getInput = InputEventJoypadButton.new()
				# grab button index
				getInput.button_index = file.get_value("controls","B"+str(actionCount)+i)
				# set device
				if (file.has_section_key("controls","B"+str(actionCount)+i+"Device")):
					getInput.device = file.get_value("controls","B"+str(actionCount)+i+"Device")
				# set new input
				InputMap.action_add_event(i,getInput)
			# joypad Axis check
			if (file.has_section_key("controls","A"+str(actionCount)+i) and
			file.has_section_key("controls","V"+str(actionCount)+i)):
				# define new key
				var getInput = InputEventJoypadMotion.new()
				# grab axis
				getInput.axis = file.get_value("controls","A"+str(actionCount)+i)
				getInput.axis_value = file.get_value("controls","V"+str(actionCount)+i)
				# set device
				if (file.has_section_key("controls","A"+str(actionCount)+i+"Device")):
					getInput.device = file.get_value("controls","A"+str(actionCount)+i+"Device")
				# set new input
				InputMap.action_add_event(i,getInput)
			
			actionCount += 1
		# reset action counter
		actionCount = 0
