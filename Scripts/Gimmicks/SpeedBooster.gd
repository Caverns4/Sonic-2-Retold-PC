@tool
extends Area2D


@export_enum("left", "right") var boostDirection = 0
var dirMemory = boostDirection
@export var speed = 16
@export var sfx = preload("res://Audio/SFX/Gimmicks/s2br_Spring.wav")
@export var visible_sprite: bool = true

var players =[]

func _ready():
	# set direction
	$Booster.flip_h = bool(boostDirection)
	$Booster.visible = visible_sprite

func _process(_delta):
	if Engine.is_editor_hint():
		if (boostDirection != dirMemory):
			$Booster.flip_h = bool(boostDirection)
			dirMemory = boostDirection
	else:
		if players:
			for i in players:
				if i.ground == true:
					i.movement.x = speed*(-1+(boostDirection*2))*60
					i.horizontalLockTimer = (15.0/60.0) # lock for 15 frames
					if sfx:
						SoundDriver.play_sound2(sfx)

func _on_SpeedBooster_body_entered(body):
	# DO THE BOOST, WHOOOOOSH!!!!!!!
	if body.ground:
		#If the sign is the same and player is moving slower.
		var sameDir = sign(body.movement.x) == sign(-1+(boostDirection*2))
		#Don't change speed if player is already moving to fast.
		if (sameDir and abs(body.movement.x) < abs(speed*60)) or !sameDir:
			body.movement.x = speed*(-1+(boostDirection*2))*60
		body.horizontalLockTimer = (15.0/60.0) # lock for 15 frames
		if sfx:
			SoundDriver.play_sound2(sfx)
		# exit out of state on certain states
	else:
		match(body.currentState):
			body.STATES.GLIDE:
				if !body.ground:
					body.animator.play("run")
					body.set_state(body.STATES.AIR)
			_:
				players.append(body)


func _on_body_exited(body: Node2D) -> void:
	if players.has(body):
		players.erase(body)
