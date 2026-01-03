@tool
extends DataSelectPanel

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var parent = get_parent().get_parent()
var anim_time: float = 0
var slot_to_delete: DataSelectPanel = null

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if parent.delete_slot == self:
		anim_time += delta
		%CharacterIcon.global_position.x = get_parent().get_child(parent.current_selection).global_position.x+40
	else:
		%CharacterIcon.global_position.x = move_toward(%CharacterIcon.global_position.x,
		global_position.x+40,delta*160)

func _input(_event: InputEvent) -> void:
	if slot_to_delete:
		if Input.is_action_just_pressed("gm_left"):
			DeleteSelectedFile(slot_to_delete)
		if Input.is_action_just_pressed("gm_right"):
			ClearDeletionState()

func update_selection_state(state: bool) -> void:
	if state:
		$DataBox.modulate = Color.YELLOW
	else:
		$DataBox.modulate = Color.WHITE

func update_menu_item(_direction: int = 0):
	return false


func use():
	parent.title_bar.text = "[center]DELETE DATA"
	parent.state = parent.MENU_STATE.DELETE_FILE
	parent.delete_slot = self
	animator.play("spin")
	anim_time = 0.0
	return false

func ClearDeletionState():
	parent.title_bar.text = "[center]SELECT DATA"
	animator.play("RESET")
	parent.delete_slot = null
	slot_to_delete = null
	await get_tree().create_timer(0.5).timeout
	parent.state = parent.MENU_STATE.SAVE_SELECT

func ConfirmDeletion(selected_save_slot: DataSelectPanel):
	parent.state = parent.MENU_STATE.DECIDED
	animator.play("delete")
	slot_to_delete = selected_save_slot

func DeleteSelectedFile(selected_save_slot: DataSelectPanel):
	if selected_save_slot.save_game_id:
		selected_save_slot.data.clear()
		selected_save_slot.level_id = Global.ZONES.EMERALD_HILL
		selected_save_slot.text_label.text = "no save"
	ClearDeletionState()
