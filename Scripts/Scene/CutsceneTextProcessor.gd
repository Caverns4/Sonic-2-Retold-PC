extends CanvasLayer

@export_multiline var cutsceneTexts: Array[String]
@export var printSpeed = 0.1

@onready var textField = $Labels/CustsceneText

var delaycounter = 0.5
var textboxID = 0
var currentCharacter = 0
var currentString = ""

func _ready() -> void:
	currentString = cutsceneTexts[textboxID]
	textField.bbcode_text = currentString
	textField.visible_characters = 0
	

func _process(delta: float) -> void:
	delaycounter -= delta
	if delaycounter <= 0 and currentCharacter < currentString.length():
		currentCharacter+=1
		delaycounter = printSpeed
		#textField.text = currentString.left(currentCharacter)
		textField.visible_characters += 1
		

func AdvanceTextbox():
	textboxID+=1
	currentCharacter = 0
	currentString = cutsceneTexts[textboxID]
	textField.bbcode_text = currentString
	textField.visible_characters = 0
	delaycounter = printSpeed
	
