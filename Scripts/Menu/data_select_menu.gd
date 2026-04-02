extends Control

@export var music: AudioStream = preload("res://Audio/Soundtrack/s2br_Options.ogg")
@export var demo_flag: bool = false
@export var demo_level: Global.ZONES = Global.ZONES.TROPICAL

var popup_path: PackedScene = preload("res://Entities/MenuObjects/save_file_popup_menu.tscn")
var delete_popup: PackedScene = preload("res://Entities/MenuObjects/delete_file_popup_menu.tscn")
var level_select_popup: PackedScene = preload("res://Entities/MenuObjects/Level_Select_popup_menu.tscn")

var title_scene: String = "res://Scene/Presentation/Title.tscn"
var zone_loader: String = "res://Scene/Presentation/ZoneLoader.tscn"

enum MENU_STATE{SAVE_SELECT,DELETE_FILE,DECIDED}
var state: int = 0

var selected_save_slot: DataSelectPanel = null

@onready var title_bar: RichTextLabel = $CanvasTop/GameModeText
@onready var options_button: Button = $OptionsButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundDriver.music.stream = music
	SoundDriver.music.play()
	
	var index: int = 0
	for child:DataSelectPanel in %SaveFileContainer.get_children():
		if demo_flag and index > 0:
			child.queue_free()
		else:
			child.save_game_id = index
			child.press.connect(panel_pressed)
			child.select.connect(on_hover)
		index += 1
	%SaveFileContainer.get_child(0).grab_focus()
	if demo_flag:
		$CanvasTop.queue_free()
		%SaveFileContainer.visible = false
		await panel_pressed($ScrollContainer/SaveFileContainer/NoSavePanel)

func _physics_process(_delta: float) -> void:
	if !selected_save_slot and Input.is_action_just_pressed("ui_super"):
		await show_delete_options()
	elif !selected_save_slot and Input.is_action_just_pressed("ui_cancel"):
		await Main.change_scene(title_scene)
		state = MENU_STATE.DECIDED

func show_delete_options() -> void:
	if !selected_save_slot is DataSelectPanel:
		return
	if selected_save_slot.save_game_id > 0 and selected_save_slot.data:
		await set_controls_locked_state(true)
		var delete_popup_scene: GeneralPopUpMenu = delete_popup.instantiate()
		delete_popup_scene.file_number = selected_save_slot.save_game_id
		add_child(delete_popup_scene)
		var menu_option: int = await delete_popup_scene.menu_exit
		if menu_option > 0: #Delete save file
			selected_save_slot.data.clear()
			selected_save_slot.level_id = Global.ZONES.EMERALD_HILL
			selected_save_slot._update_save_preview()
		await set_controls_locked_state(false)
	elif selected_save_slot.save_game_id == 0 and Global.debug_mode:
		await set_controls_locked_state(true)
		var level_scene: GeneralPopUpMenu = level_select_popup.instantiate()
		add_child(level_scene)
		var menu_option: int = await level_scene.menu_exit
		if menu_option >= 0: #Level Select
			selected_save_slot.level_id = menu_option as Global.ZONES
		await set_controls_locked_state(false)

func panel_pressed(new_save: DataSelectPanel) -> void:
	var popup_scene: SavePopupMenu = popup_path.instantiate()
	selected_save_slot = new_save
	popup_scene.save_file_id = new_save.save_game_id
	popup_scene.save_data = selected_save_slot.data
	await set_controls_locked_state(true)

	add_child(popup_scene)
	var menu_option: int = await popup_scene.menu_exit
	if menu_option < 0: # Cancel
		if !demo_flag:
			await set_controls_locked_state(false)
			await get_tree().process_frame
		else:
			state = MENU_STATE.DECIDED
			await Main.change_scene(title_scene)
	else:
		if !selected_save_slot.data:
			selected_save_slot.character_id = menu_option
			selected_save_slot._update_save_preview()
		else:
			selected_save_slot.level_id = menu_option as Global.ZONES
			selected_save_slot._update_save_preview()
		await UseSelectedItem()

func on_hover(child: DataSelectPanel) -> void:
	selected_save_slot = child


func set_controls_locked_state(lock_state: bool) -> void:
	var all_buttons: Array[Button] = [options_button]
	for butt:Button in %SaveFileContainer.get_children():
		all_buttons.append(butt)
	for i:Button in all_buttons:
		i.disabled = lock_state
		if lock_state:
			i.focus_mode = Control.FOCUS_NONE
		else:
			i.focus_mode = Control.FOCUS_ALL
	await get_tree().process_frame
	if !lock_state:
		selected_save_slot.grab_focus()

func UseSelectedItem() -> void:
	selected_save_slot.use()
	if !selected_save_slot.data:
		GlobalFunctions.convert_player_mode_to_players(selected_save_slot.character_id)
		if demo_flag:
			selected_save_slot.level_id = demo_level
	
	Global.saved_zone_id = selected_save_slot.level_id
	await Main.change_scene(zone_loader)
	state = MENU_STATE.DECIDED


func _on_options_button_pressed() -> void:
	if !selected_save_slot:
		return
	else:
		await show_delete_options()
	
