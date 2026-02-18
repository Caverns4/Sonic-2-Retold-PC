extends Control

@export var music = preload("res://Audio/Soundtrack/s2br_Options.ogg")

var popup_path: PackedScene = preload("res://Entities/MenuObjects/save_file_popup_menu.tscn")

var title_scene: String = "res://Scene/Presentation/Title.tscn"
var zone_loader: String = "res://Scene/Presentation/ZoneLoader.tscn"

enum MENU_STATE{SAVE_SELECT,DELETE_FILE,DECIDED}
var state = 0

var selected_save_slot: DataSelectPanel = null

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
		else:
			pass
		UseSelectedItem()
	

func set_controls_locked_state(lock_state: bool):
		#$ScrollContainer.
		for i in %SaveFileContainer.get_children():
			i.disabled = lock_state
		await get_tree().process_frame
		if selected_save_slot.disabled == false:
			selected_save_slot.grab_focus()
		

func UseSelectedItem():
	selected_save_slot.use()
	if !selected_save_slot.data:
		GlobalFunctions.convert_player_mode_to_players(selected_save_slot.character_id)
	
	Global.saved_zone_id = selected_save_slot.level_id
	Main.change_scene(zone_loader)
	state = MENU_STATE.DECIDED
