extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_2PResults.ogg")
var zone_loader: String = "res://Scene/Presentation/ZoneLoader.tscn"
var two_player_menu: String = "res://Scene/Presentation/TwoPlayerMenu.tscn"

var results = 0 #Winner of the current act, or zone if zone is complete.
var endScene = false

func _ready():
	SoundDriver.music.stream = music
	SoundDriver.music.play()
	var result = [0,0,0,0,0,0]
	if Global.twoPlayActResults:
		result = Global.twoPlayActResults[Global.twoPlayActResults.size()-1]
	var winner = GetWinner(result)
	
	#Calculate Time Text
	var time = result[1]
	var timeTextP1: String = "%2d" % floor(time/60) + ":" + str(fmod(floor(time),60)).pad_zeros(2) + ":" + str(fmod(floor(time*100),100)).pad_zeros(2)
	time = result[4]
	var timeTextP2: String = "%2d" % floor(time/60) + ":" + str(fmod(floor(time),60)).pad_zeros(2) + ":" + str(fmod(floor(time*100),100)).pad_zeros(2)
	
	$"UI/Labels/Act Results Text".text = ("Act " + str(Global.savedActID+1) + " results\n\n"
	+ "SCORE  " + str(result[0]).lpad(6) + " :   " + str(result[3]).lpad(6) + "\n\n"
	+ "TIME " + timeTextP1 + " : " + timeTextP2 + "\n\n"
	+ "RINGS     " + str(result[2]).lpad(3) + " :      " + str(result[5]).lpad(3) + "\n\n")
	
	Global.twoPlayActResultsFinal.insert(winner,Global.twoPlayActResultsFinal.size())
	
	if winner > 0:
		$UI/Labels/WinnerText.text = "[center]1P WINS"
	elif winner == 0:
		$UI/Labels/WinnerText.text = "[center]TIED"
	else:
		$UI/Labels/WinnerText.text = "[center]2P WINS"

func _input(event):
	if !endScene:
		# finish character select if start is pressed
		if (event.is_action_pressed("gm_pause")
		or event.is_action_pressed("gm_action")
		or event.is_action_pressed("gm_action2")
		or event.is_action_pressed("gm_action3")) and !endScene:
			endScene = true
			Global.score = 0
			Global.scoreP2 = 0
			if Global.savedActID == 0 and Global.lives > 0 and Global.livesP2 > 0:
				Global.loadNextLevel()
				Global.main.change_scene(zone_loader)
			else:
				Global.twoPlayerZoneResults.append(results)
				Global.main.change_scene(two_player_menu)

func GetWinner(result: Array):
	if Global.lives <=0:
		return -1 #If a Game Over was obtained, the other Player wins.
	if Global.livesP2 <=0:
		return 1
	
	# For each pair of numbers, subtract Player 1's result from Player 2's, and
	# get the signature. If it's negative, we know Player 2's value was higher.
	#For the time, however, the winner needs to be LESS
	var a = sign(result[0]-result[3])
	var b = sign(result[4]-result[1])
	var c = sign(result[2]-result[5])
	#print(str(a) + str(b) + str(c) )
	var winner = (a+b+c)
	return winner
