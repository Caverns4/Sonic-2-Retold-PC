@tool
extends DataSelectPanel


func update_selection_state(state: bool) -> void:
	if state:
		$DataBox.modulate = Color.YELLOW
	else:
		$DataBox.modulate = Color.WHITE

func update_menu_item(_direction: int = 0):
	pass


func use():
	return false
	
