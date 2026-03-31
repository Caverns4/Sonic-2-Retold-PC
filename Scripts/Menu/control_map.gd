extends Control

func _process(_delta: float) -> void:
	debug_inputs()

func debug_inputs() -> void:
	var input_list: Array = [
		Input.is_action_pressed("ui_up"),
		Input.is_action_pressed("ui_down"),
		Input.is_action_pressed("ui_left"),
		Input.is_action_pressed("ui_right"),
		Input.is_action_pressed("ui_pause"),
		Input.is_action_pressed("ui_accept"),
		Input.is_action_pressed("ui_select"),
		Input.is_action_pressed("ui_cancel"),
		Input.is_action_pressed("ui_super")
	]
	var icons: Array = [
		$up,
		$down,
		$left,
		$right,
		$start,
		$A,
		$B,
		$C,
		$Y,
	]
	for i in input_list.size():
		icons[i].visible = input_list[i]
