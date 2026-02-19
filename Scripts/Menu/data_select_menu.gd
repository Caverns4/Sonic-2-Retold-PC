extends Control

@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")

var popup_path: PackedScene = preload("res://Entities/MenuObjects/save_file_popup_menu.tscn")
var delete_popup: PackedScene = preload("res://Entities/MenuObjects/delete_file_popup_menu.tscn")

var title_scene: String = "res://Scene/Presentation/Title.tscn"
var zone_loader: String = "res://Scene/Presentation/ZoneLoader.tscn"

enum MENU_STATE{SAVE_SELECT,DELETE_FILE,DECIDED}
var state = 0

var selected_save_slot: DataSelectPanel = null

@onready var title_bar: RichTextLabel = $CanvasTop/GameModeText

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

func _physics_process(_delta: float) -> void:
	if !selected_save_slot and Input.is_action_just_pressed("gm_super"):
		show_delete_options()
	#	print("options")
	#print(get_viewport().gui_get_focus_owner())

func show_delete_options():
	selected_save_slot = get_viewport().gui_get_focus_owner()
	if selected_save_slot is DataSelectPanel and selected_save_slot.save_game_id > 0:
		var delete_popup_scene: GeneralPopUpMenu = delete_popup.instantiate()
		set_controls_locked_state(true)
		add_child(delete_popup_scene)
		var menu_option: int = await delete_popup_scene.menu_exit
		if menu_option > 0: #Delete save file
			selected_save_slot.data.clear()
			selected_save_slot.level_id = Global.ZONES.EMERALD_HILL
			selected_save_slot._update_save_preview()
		set_controls_locked_state(false)
	await get_tree().process_frame
	selected_save_slot = null

func use(save_file_id: int):
	var popup_scene: SavePopupMenu = popup_path.instantiate()
	selected_save_slot = %SaveFileContainer.get_child(save_file_id)
	popup_scene.save_file_id = save_file_id
	popup_scene.save_data = selected_save_slot.data
	set_controls_locked_state(true)

	add_child(popup_scene)
	var menu_option: int = await popup_scene.menu_exit
	if menu_option < 0: # Cancel
		set_controls_locked_state(false)
		await get_tree().process_frame
		selected_save_slot = null
	else:
		if !selected_save_slot.data:
			selected_save_slot.character_id = menu_option
			selected_save_slot._update_save_preview()
		else:
			selected_save_slot.level_id = menu_option as Global.ZONES
			selected_save_slot._update_save_preview()
		UseSelectedItem()
	

func set_controls_locked_state(lock_state: bool):
		#$ScrollContainer.
		for i:Button in %SaveFileContainer.get_children():
			i.disabled = lock_state
			if lock_state:
				i.focus_mode = Control.FOCUS_NONE
			else:
				i.focus_mode = Control.FOCUS_ALL
		await get_tree().process_frame
		if !lock_state:
			selected_save_slot.grab_focus()




func UseSelectedItem():
	selected_save_slot.use()
	if !selected_save_slot.data:
		GlobalFunctions.convert_player_mode_to_players(selected_save_slot.character_id)
	
	Global.saved_zone_id = selected_save_slot.level_id
	Main.change_scene(zone_loader)
	state = MENU_STATE.DECIDED
