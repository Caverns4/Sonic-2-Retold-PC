extends Node2D

const SCORE = [10,100,200,500,1000,10000]

var scoreID: int = 0
var playerID: int = 0

var yspeed: float = -3

func _ready() -> void:
	# check if adding score would hit the life bonus
	await Global.check_score_life(SCORE[scoreID])
	
	# add score
	if playerID == 0 or !Global.two_player_mode:
		Global.score += SCORE[scoreID]
	else:
		Global.scoreP2 += SCORE[scoreID]
	$Sprite2D.frame = scoreID
	

func _physics_process(delta: float) -> void:
	# move score
	yspeed += 0.09375*60*delta
	translate(Vector2(0,yspeed*60*delta))
	if yspeed >= 0:
		queue_free()
