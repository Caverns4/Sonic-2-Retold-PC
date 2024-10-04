extends Node2D

@export_enum("Tube Up", "Tube Down", "Arc Clockwise", "Arc CounterClowise") var behavior = 0
@export_range (1, 128) var wormCount = 6
@export var gloopSound = preload("res://Audio/SFX/Gimmicks/MegaMackGloop.ogg")

var child = preload("res://Entities/ZoneObjects/MackWorms.tscn")
var origin = Vector2.ZERO

enum STATES{BOTTOM,UP_TUBE,TOP,DOWN_TUBE,ARCHING}
var childStates = []
var soundCheck = false

# The initial time for each child before moving. * delta when using this.
var childTimes = [
	 0.0
]
# Fake Child velocity.
var childSpeeds = [
	Vector2.ZERO
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set up initial values
	origin = global_position
	var initialState = STATES.BOTTOM
	var initialPosition = global_position
	if behavior == 1: #Start at top
		initialState = STATES.TOP
		initialPosition.y = origin.y-80
	elif behavior == 3: #Arc left
		initialPosition.x = origin.x+96
	
	var nextChild = null
	var childTimer = 3/60.0
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
			get_child(i).global_position = initialPosition
			childTimes.insert(childTimes.size(),childTimer)
			childTimer += (3/60.0)
			childSpeeds.insert(childSpeeds.size(),Vector2.ZERO)
			

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
			STATES.ARCHING:
				ArcMotion(i,delta)

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

func ArcMotion(i,delta):
	var currentChild = get_child(i)
	#Do speed update first
	currentChild.global_position += childSpeeds[i]
	#add gravity
	childSpeeds[i].y += ((0.09375/64.0)/GlobalFunctions.div_by_delta(delta))
	childSpeeds[i].y = clampf(childSpeeds[i].y,-4.5,4.5)
	# Add acceleration
	var accel =  abs((11.00/4.0)*delta)
	if currentChild.global_position.x > origin.x + 48:
		childSpeeds[i].x -= accel
	else:
		childSpeeds[i].x += accel
		

	
	if currentChild.global_position.y > origin.y:
		childTimes[i] = 1.0
		childSpeeds[i] = Vector2.ZERO
		childStates[i] = STATES.BOTTOM
		get_child(i).monitoring = false
		#Set position for next jump
		if currentChild.global_position.x > origin.x + 48:
			currentChild.global_position = Vector2(origin.x+96, origin.y)
		else:
			currentChild.global_position = origin

func WaitTimer(i):
	var currentChild = get_child(i)
	#print(childTimes[i])
	if childTimes[i] <= 0.0:
		if behavior > 1: #If type is arching
			childStates[i] = STATES.ARCHING
			childSpeeds[i] = Vector2(0,-4.5)
			QueuePipeSoundEffect()
			currentChild.monitoring = true
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
	
