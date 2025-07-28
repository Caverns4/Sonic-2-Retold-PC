@tool
extends Node2D

@export var bottom_distance = 2

var players = []
var playerPosX = []
var activePlayers = []
var is_falling = false
var fallSpeed = 60

func _ready():
	$ScrewBottom.position.y = (bottom_distance*8)+4


func _process(_delta):
	if Engine.is_editor_hint():
		$ScrewBottom.position.y = (bottom_distance*8)+4

func _physics_process(delta):
	if !Engine.is_editor_hint():
		if is_falling:
			fallSpeed += 60*delta
			$Screw.position.y += fallSpeed*delta
			_respawnCheck()
			# stop processing
			return
		
		# check if to lock player
		for i in players:
			# check if player position crossed the middle
			if sign(global_position.x-i.global_position.x) != sign(global_position.x-i.global_position.x+(i.movement.x*delta)) or (round(global_position.x-i.global_position.x)/4) == 0:
				if !activePlayers.has(i):
					activePlayers.append(i)
		
		# variable to calculate length of movement
		var moveOffset = 0
		
		for i in activePlayers:
			# movement power
			var goDirection = i.movement.x*delta/4
			
			if ((!$Screw/FloorCheck.is_colliding() or goDirection > 0) and (!$Screw/CeilingCheck.is_colliding() or goDirection < 0)
			and !is_falling and i.ground):
				i.global_position.x = global_position.x
				$Screw/Screw.frame = posmod(int(floor(-$Screw.position.y/4)),4)
			else:
				activePlayers.erase(i)
			
			# increase move offset by how fast hte player is moving
			moveOffset += -goDirection
			if $Screw.position.y > bottom_distance*8:
				is_falling = true
		$Screw.position.y += moveOffset
		_respawnCheck()

func _respawnCheck():
	#Respawn check
	if !players:
		var rangetest = GlobalFunctions.get_nearest_player_x(global_position.x).global_position.x
		rangetest -= global_position.x
		if abs(rangetest) >= 320 and $Screw.position.y != -4:
			$Screw.position.y = -4
			is_falling = false

func _on_playerChecker_body_entered(body):
	if !players.has(body):
		players.append(body)


func _on_playerChecker_body_exited(body):
	if players.has(body):
		players.erase(body)


# prevent unnecessary run time processing for object
func _on_DeathTimer_timeout():
	is_falling = false
	set_physics_process(false)
	$Screw.queue_free()
