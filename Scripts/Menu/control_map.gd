extends Control

func _process(_delta: float) -> void:
	debug_inputs()

func debug_inputs():
	var input_list = [
		Input.is_action_pressed("gm_up"),
		Input.is_action_pressed("gm_down"),
		Input.is_action_pressed("gm_left"),
		Input.is_action_pressed("gm_right"),
		Input.is_action_pressed("gm_pause"),
		Input.is_action_pressed("gm_action"),
		Input.is_action_pressed("gm_action2"),
		Input.is_action_pressed("gm_action3"),
		Input.is_action_pressed("gm_super")
	]
	var icons = [
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
