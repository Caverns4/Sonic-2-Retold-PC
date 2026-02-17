extends Node

# returns an int, 0 = none, 1 = pressed, 2 = held (you'll most likely want to do > 0 if you're checking for pressed)
func calculate_input(event, action = "gm_action"):
	return int(event.is_action(action) or event.is_action_pressed(action))-int(event.is_action_released(action))

# get the current active camera
func getCurrentCamera2D():
	var viewport = get_viewport()
	if not viewport:
		return null
	var camerasGroupName = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)
	for camera in cameras:
		if camera is Camera2D and camera.enabled:
			return camera
	return null

func get_chaos_emerald_count(value: int):
	var index: int = 1
	var emerald_count: int = 0
	while index < 255:
		if (value & index) > 0:
			emerald_count +=1
		index += index
	return emerald_count


# the original game logic runs at 60 fps, this function is meant to be used to help calculate this,
# usually a division by the normal delta will cause the game to freak out at different FPS speeds
func div_by_delta(delta):
	return 0.016667*(0.016667/delta)

# get window size resolution as a vector2
func get_screen_size():
	return get_viewport().get_visible_rect().size

## Return the nearest player by x_pos
func get_nearest_player_x(x_pos: float):
	var closest = null #closest x distance
	var finalObj = null #Output object
	for player in Global.players: #number of applicable players
		var result = absf(x_pos - (player.global_position.x))
		if !closest or closest > result:
			closest = result
			finalObj = player
	return finalObj

## Return the nearest player by total distance
func get_nearest_player(obj_pos: Vector2):
	var closest = null #closest distance
	var finalObj = null #Output object
	for player in Global.players: #number of applicable players
		var result = obj_pos.distance_to(player.global_position)
		if !closest or closest > result:
			closest = result
			finalObj = player
	return finalObj

## Return position of nearest player in a Vector2
func get_orientation_to_player(obj_pos: Vector2):
	if Global.players:
		var player = get_nearest_player(obj_pos)
		return player.global_position - obj_pos
	else:
		return Vector2.ZERO
