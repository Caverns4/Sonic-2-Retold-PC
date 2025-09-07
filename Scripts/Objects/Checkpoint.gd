extends Area2D
var active = false
@export var checkPointID = 0

var specialStageEntry = preload("res://Entities/Items/CheckpointStars.tscn")

var PlayerMemory = [] #List of Players that have triggered this Checkpoint

func _ready():
	# add self to global check point list (it's cleared in the stage start script in global)
	Global.checkPoints.append(self)
	
	# if we're the current checkpoint then activate on level start
	if Global.currentCheckPoint == checkPointID:
		# give a frame to to check activation
		await get_tree().process_frame
		$Spinner.queue("flash")
		active = true
		for i in Global.checkPoints:
			if i.get("checkPointID") != null:
				if i.checkPointID < checkPointID:
					i.active = true
					i.get_node("Spinner").play("flash")


func activate(playerNode: Player2D):
	
	# queue flash, incase an animation is already playing
	$Spinner.queue("flash")
	active = true
	Global.currentCheckPoint = checkPointID
	
	#Save player 1 data if main character passes.
	if playerNode == Global.players[0]:
		Global.checkPointTime = Global.levelTime
		Global.checkPointRings = playerNode.rings
	#save player 2 data if sidekick passed.
	elif Global.two_player_mode == true and !Global.players[0] == playerNode:
		Global.checkPointTimeP2 = Global.levelTimeP2
		Global.checkPointRingsP2 = playerNode.rings
	
	# set checkpoint to self (and set any checkpoitns with a lower ID to active)
	for i in Global.checkPoints:
		if i.get("checkPointID") != null:
			if i.checkPointID < checkPointID:
				i.active = true
				i.get_node("Spinner").play("flash")
	
	if (!Global.two_player_mode and Global.players[0].rings > 49
	and Global.emeralds < 127): #If 1P, >=50 rings, > 7 emeralds...
		var spawn = specialStageEntry.instantiate()
		spawn.global_position = global_position + Vector2(0,-64)
		get_parent().call_deferred("add_child",spawn)
		#add_child(spawn)

func _on_Checkpoint_body_entered(body):
	# do the spin and activate
	if !active and !Global.two_player_mode:
		if body.playerControl == 1:
			$Spinner.play("spin")
			$Checkpoint.play()
			activate(body)
	if Global.two_player_mode and !PlayerMemory.has(body):
			$Spinner.play("spin")
			$Checkpoint.play()
			activate(body)
			PlayerMemory.append(body)
			body.respawnPosition = global_position
	
