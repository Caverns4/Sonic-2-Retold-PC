extends Node2D

@export var music = preload("res://Audio/Soundtrack/s2br_2PResults.ogg")
var nextAct = preload("res://Scene/Presentation/ZoneLoader.tscn")
var returnScene = preload("res://Scene/Presentation/TwoPlayerMenu.tscn")

var results = 0 #Winner of the current act, or zone if zone is complete.
var endScene = false

func _ready():
	Global.music.stream = music
	Global.music.play()
	var result = Global.twoPlayActResults[Global.twoPlayActResults.size()-1]
	var winner = GetWinner()
	$"UI/Labels/Act Results Text".text = ("Act results " + str(Global.savedActID+1) + "\n\n"
	+ "SCORE  " + str(result[0]).lpad(6) + " : " + str(result[3]).lpad(6) + "\n"
	+ "RINGS     " + str(result[2]).lpad(3) + " :    " + str(result[5]).lpad(3) + "\n")
	
	Global.twoPlayActResultsFinal.insert(winner,Global.twoPlayActResultsFinal.size())
	
	if winner > 0:
		$UI/Labels/WinnerText.text = "1P WINS"
	elif winner == 0:
		$UI/Labels/WinnerText.text = "TIED"
	else:
		$UI/Labels/WinnerText.text = "2P WINS"

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
				Global.savedActID +=1
				Global.loadNextLevel
				Global.main.change_scene_to_file(nextAct,"FadeOut","FadeOut",1)
			else:
				Global.twoPlayerZoneResults
				Global.main.change_scene_to_file(returnScene,"FadeOut","FadeOut",1)

func GetWinner():
	if Global.lives <=0:
		return -1 #If a Game Over was obtained, the other Player wins.
	if Global.livesP2 <=0:
		return 1
	
	#Prepare the results:
	var result = Global.twoPlayActResults[Global.twoPlayActResults.size()-1]
	var a = 0 # No Contest
	var b = 0 # No Contest
	var c = 0 # No Contest
	# For each pair of numbers, subtract Player 1's result from Player 2's, and
	# get the signature. If it's negative, we know Player 2's value was higher.
	#For the time, however, the winner needs to be LESS
	a = sign(result[0]-result[3])
	b = sign(result[4]-result[1])
	c = sign(result[2]-result[5])
	#print(str(a) + str(b) + str(c) )
	var winner = (a+b+c)
	return winner
