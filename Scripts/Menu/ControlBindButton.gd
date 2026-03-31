extends Button

## Input name to get from project settings
@export var bind: String = ""
## index to get from the specified input, if possible.
@export var bind_index: int = 0

var player_index: int = 0

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

## String to append for two-player action checks.
const PLAYER2STR: String = "_P2"

@onready var control_menu: ControllerMenu = get_parent().get_parent()

func _init() -> void:
	toggle_mode = true

func _ready() -> void:
	set_process_unhandled_input(false)
	update_text()

func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if toggled_on:
		text = "Press key..."
		control_menu.set_unchecked_buttons(self,true)
	else:
		disabled = true
		update_text()
		control_menu.set_unchecked_buttons(self,false)
		await get_tree().create_timer(0.5).timeout
		disabled = false

func _unhandled_input(event: InputEvent) -> void:
	var input_str: String = bind+PLAYER2STR if (player_index > 0) else bind
	
	if event.is_pressed():
		var events: Array = InputMap.action_get_events(input_str).duplicate_deep()
		
		## Rebuild the array. There is an anforced pattern: Keyboard key, Joypad button, analog index.
		var new_event_array: Array = []
		if event is InputEventKey:
			new_event_array.append(event)
			print("Keyboard assignment")
		else:
			new_event_array.append(events[0])
		if event is InputEventJoypadButton:
			new_event_array.append(event)
			print("Joybutton assignment")
		else:
			for saved: InputEvent in events:
				if saved is InputEventJoypadButton:
					new_event_array.append(saved)
					break
		if event is InputEventJoypadMotion:
			new_event_array.append(event)
			print("Joymotion assignment")
		else:
			for saved: InputEvent in events:
				if saved is InputEventJoypadMotion:
					new_event_array.append(saved)
					break
	
		if new_event_array.has(event):
			InputMap.action_erase_events(input_str)
			for i: InputEvent in new_event_array:
				InputMap.action_add_event(input_str,i)
				print("Append " + str(i.as_text()))
			button_pressed = false
			control_menu.load_button_strings()
		else:
			print("Button assignment failed!")
			return
		return

func update_text() -> void:
	var input_str: String = bind+PLAYER2STR if (player_index > 0) else bind
	var events: Array = InputMap.action_get_events(input_str)
	if events.size() > bind_index:
		if events[bind_index] is InputEventJoypadButton:
			text = events[bind_index].as_text().right(8).trim_suffix(")")
			text = "JP btn " + str(events[bind_index].button_index)
		elif events[bind_index] is InputEventJoypadMotion:
			text = str(joyAxisNameList[events[bind_index].axis]+str(int(events[bind_index].axis_value)))
		else:
			text = InputMap.action_get_events(input_str)[bind_index].as_text()
	else:
		text = "---"
