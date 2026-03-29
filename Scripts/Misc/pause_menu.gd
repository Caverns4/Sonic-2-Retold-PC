class_name PauseScene
extends Control

var yesno_menu_scene: PackedScene = preload("res://Entities/MenuObjects/yes_no_popup_menu.tscn")

var options_menu: PackedScene = preload("res://Scene/Presentation/OptionsMenu.tscn")

@onready var background: TextureRect = $PauseCover
@onready var menu_text: VBoxContainer = $PauseMenu/VBoxContainer
@onready var continue_button: Button = %Continue
@onready var options_button: Button = %Options
@onready var restart_button: Button = %Restart
@onready var quit_button: Button = %Quit
## Last saved menu button
var menu_option: Button = null


func  _ready() -> void:
	menu_option = continue_button

func set_control_lock_state(state: bool) -> void:
	for i in menu_text.get_children():
		if i is Button:
			i.disabled = state
			if state:
				i.focus_mode = Control.FOCUS_NONE
			else:
				i.focus_mode = Control.FOCUS_ALL
	if menu_option and menu_option.disabled == false:
		await get_tree().process_frame
		menu_option.grab_focus()


func _input(event: InputEvent) -> void:
	# check if paused and visible, otherwise cancel it out
	if !get_tree().paused or !visible:
		return
	if (event.is_action_pressed("gm_pause") or 
	event.is_action_pressed("gm_pause_P2")) and (continue_button.disabled == false):
		if Main.can_pause:
			await get_tree().process_frame
			get_tree().paused = false
			visible = false

func _on_visibility_changed() -> void:
	if visible:
		await set_control_lock_state(false)
		if background:
			var img: Image = get_viewport().get_texture().get_image()
			var tex: Texture2D = ImageTexture.create_from_image(img)
			background.texture = tex

func _on_continue_pressed() -> void:
	menu_option = continue_button
	await set_control_lock_state(true)
	await get_tree().process_frame
	get_tree().paused = false
	visible = false


func _on_restart_pressed() -> void:
	menu_option = restart_button
	await set_control_lock_state(true)
	
	var agree_menu: YesNoPopUpMenu = yesno_menu_scene.instantiate()
	agree_menu.start_on_yes = false
	agree_menu.question = "Are you sure you
	want to restart?
	You will lose
	unsaved progress."
	add_child(agree_menu)
	var sel: bool = await agree_menu.menu_exit
	if sel:
		await restart_level()
	else:
		await set_control_lock_state(false)


func _on_quit_pressed() -> void:
	menu_option = quit_button
	await set_control_lock_state(true)

	var agree_menu: YesNoPopUpMenu = yesno_menu_scene.instantiate()
	agree_menu.start_on_yes = false
	if Global.current_save_index == 0:
		agree_menu.question = "Are you sure you
		want to quit?
		All progress
		will be lost."
	else:
		agree_menu.question = "Are you sure you
		want to quit?
		You can continue
		from zone start."
	add_child(agree_menu)
	var sel: bool = await agree_menu.menu_exit
	if sel:
		await quit_to_title()
	else:
		await set_control_lock_state(false)


func _on_options_pressed() -> void:
	menu_option = options_button
	await set_control_lock_state(true)
	$PauseMenu/VBoxContainer.hide()
	var opt_menu: Control = options_menu.instantiate()
	add_child(opt_menu)
	await opt_menu.tree_exited
	$PauseMenu/VBoxContainer.show()
	await set_control_lock_state(false)


func restart_level() -> void:
	visible = false
	get_tree().paused = true
	Global.checkpoint_time_p1 = 0
	Global.saved_checkpoint = -1
	await Main.change_scene("","FadeOut",1,true)
	await Main.scene_faded
	SoundDriver.music.stop()
	#Main.set_volume(0)

func quit_to_title() -> void:
	visible = false
	get_tree().paused = true
	Main.can_pause = false
	await Main.reset_game()
	SoundDriver.music.stop()
	#Main.set_volume(0)
