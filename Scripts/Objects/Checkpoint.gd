extends Area2D
var active = false
@export var checkPointID = 0

var specialStageEntry = preload("res://Entities/Items/SpecialStageRing.tscn")

var PlayerMemory = [] #List of Players that have triggered this Checkpoint

func _ready():
	# add self to global check point list (it's cleared in the stage start script in global)
	Global.checkPoints.append(self)
	
	# if we're the current checkpoint then activate on level start
	if Global.currentCheckPoint == checkPointID:
		# give a frame to to check activation
		await get_tree().process_frame
		activate()


func activate():
	# queue flash, incase an animation is already playing
	$Spinner.queue("flash")
	active = true
	Global.currentCheckPoint = checkPointID
	Global.checkPointTime = Global.levelTime
	
	# set checkpoint to self (and set any checkpoitns with a lower ID to active)
	for i in Global.checkPoints:
		if i.get("checkPointID") != null:
			if i.checkPointID < checkPointID:
				i.active = true
				i.get_node("Spinner").play("flash")
	
	if (!Global.TwoPlayer and Global.players[0].rings > 50
	and Global.emeralds < 127): #If 1P, >=50 rings, > 7 emeralds...
		var spawn = specialStageEntry.instantiate()
		spawn.global_position = global_position + Vector2(0,-96)
		get_parent().add_child(spawn)

func _on_Checkpoint_body_entered(body):
	# do the spin and activate
	if !active and !Global.TwoPlayer:
		if body.playerControl == 1:
			$Spinner.play("spin")
			$Checkpoint.play()
			activate()
	if Global.TwoPlayer and !PlayerMemory.has(body):
			$Spinner.play("spin")
			$Checkpoint.play()
			activate()
			PlayerMemory.append(body)
			body.respawnPosition = global_position
	
