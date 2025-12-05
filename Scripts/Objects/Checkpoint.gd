extends Area2D
var active = false
@export var checkpoint_id = 0

var specialStageEntry = preload("res://Entities/Items/CheckpointStars.tscn")

var player_memory = [] #List of Players that have triggered this Checkpoint

func _ready():
	# add self to global check point list (it's cleared in the stage start script in global)
	Global.checkpoints.append(self)
	
	# if we're the current checkpoint then activate on level start
	if Global.saved_checkpoint == checkpoint_id:
		# give a frame to to check activation
		await get_tree().process_frame
		$Spinner.queue("flash")
		active = true
		for i in Global.checkpoints:
			if i.get("checkpoint_id") != null:
				if i.checkpoint_id < checkpoint_id:
					i.active = true
					i.get_node("Spinner").play("flash")


func activate(player: Player2D):
	
	# queue flash, incase an animation is already playing
	$Spinner.queue("flash")
	active = true
	Global.saved_checkpoint = checkpoint_id
	player.respawnPosition = global_position
	
	#Save player 1 data if main character passes.
	if player == Global.players[0]:
		Global.checkPointTime = Global.levelTime
		Global.checkPointRings = player.rings
	#save player 2 data if sidekick passed.
	elif Global.two_player_mode == true and !Global.players[0] == player:
		Global.checkPointTimeP2 = Global.levelTimeP2
		Global.checkPointRingsP2 = player.rings
	
	# set checkpoint to self (and set any checkpoitns with a lower ID to active)
	for i in Global.checkpoints:
		if i.get("checkpoint_id") != null:
			if i.checkpoint_id < checkpoint_id:
				i.active = true
				i.get_node("Spinner").play("flash")
	
	if (!Global.two_player_mode and Global.players[0].rings > 49
	and Global.emeralds < 127): #If 1P, >=50 rings, > 7 emeralds...
		var spawn = specialStageEntry.instantiate()
		spawn.global_position = global_position + Vector2(0,-64)
		get_parent().call_deferred("add_child",spawn)

func _on_Checkpoint_body_entered(body):
	# do the spin and activate
	if !active and !Global.two_player_mode:
		if body.playerControl == 1:
			$Spinner.play("spin")
			$Checkpoint.play()
			activate(body)
			Global.save_level_data(global_position)
	if Global.two_player_mode and !player_memory.has(body):
			$Spinner.play("spin")
			$Checkpoint.play()
			activate(body)
			player_memory.append(body)
	
	
