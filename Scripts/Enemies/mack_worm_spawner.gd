extends Node2D

@export_enum("Tube Up", "Tube Down", "Arc Clockwise", "Arc CounterClowise") var behavior = 0
@export_range (1, 8) var wormCount = 6
@export var gloopSound = preload("res://Audio/SFX/Gimmicks/MegaMackGloop.ogg")

var child = preload("res://Entities/ZoneObjects/MackWorms.tscn")
var origin = Vector2.ZERO

enum STATES{BOTTOM,UP_TUBE,TOP,DOWN_TUBE,ARCHING}
var childStates = []
var soundCheck = false

# The initial time for each child before moving. * delta when using this.
var childTimes = [
	 0.0,
	 3/60.0,
	 6/60.0,
	 9/60.0,
	12/60.0,
	15/60.0,
	18/60.0,
	21/60.0,
	24/60.0
]
# Fake Child velocity.
var childSpeeds = [
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO,
	Vector2.ZERO
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	origin = global_position
	
	var initialState = STATES.BOTTOM
	var initialPosition = global_position.y
	if behavior == 1:
		initialState = STATES.TOP
		initialPosition = origin.y-80
	
	var nextChild = null
	for i in wormCount-1:
		nextChild = child.instantiate()
		add_child(nextChild)
		move_child($VisibleOnScreenEnabler2D,get_child_count())
		$VisibleOnScreenEnabler2D.visible = true
	for i in get_child_count(true)-1:
		var currentChild = get_child(i)
		if currentChild is Area2D:
			get_child(i).monitoring = false
			childStates.append(initialState)
			get_child(i).global_position.y = initialPosition

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Mack Worm movement will be ontrolled entirely in this one script.
func _physics_process(delta):
	for i in get_child_count(true)-1:
		childTimes[i] -= (1.0*delta)
		match childStates[i]:
			STATES.BOTTOM:
				WaitTimer(i)
			STATES.UP_TUBE:
				DoTubeMotion(i,delta)
			STATES.TOP:
				WaitTimer(i)
			STATES.DOWN_TUBE:
				DoTubeMotion(i,delta)

func DoTubeMotion(i,delta):
	var currentChild = get_child(i)
	
	if childStates[i] == STATES.UP_TUBE:
		childSpeeds[i].y -= (0.09375/GlobalFunctions.div_by_delta(delta))
	else:
		childSpeeds[i].y += (0.09375/GlobalFunctions.div_by_delta(delta))
	
	childSpeeds[i].y = clampf(childSpeeds[i].y,-4.5,4.5)
	currentChild.global_position += childSpeeds[i]
	
	if currentChild.global_position.y >= origin.y:
		currentChild.global_position.y = origin.y
		if childStates[i] == STATES.DOWN_TUBE:
			childTimes[i] = 1.0
			childStates[i] = STATES.BOTTOM
			get_child(i).monitoring = false
	
	if currentChild.global_position.y <= origin.y - 80:
		currentChild.global_position.y = origin.y - 80
		if childStates[i] == STATES.UP_TUBE:
			childTimes[i] = 1.0
			childStates[i] = STATES.TOP
			get_child(i).monitoring = false

func WaitTimer(i):
	var currentChild = get_child(i)
	#print(childTimes[i])
	if childTimes[i] <= 0.0:
		if childStates[i] == STATES.BOTTOM:
			childStates[i] = STATES.UP_TUBE
			QueuePipeSoundEffect()
			currentChild.monitoring = true
		if childStates[i] == STATES.TOP:
			childStates[i] = STATES.DOWN_TUBE
			QueuePipeSoundEffect()
			currentChild.monitoring = true

# Try to play the pipe sound. Only ever *other* queue should play.
func QueuePipeSoundEffect():
	if soundCheck:
		soundCheck = false
		Global.play_sound(gloopSound)
	else:
		soundCheck = true
	
