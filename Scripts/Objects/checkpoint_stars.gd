extends Node2D

const MAXSPEED = 1.5

enum STATES{INTRO,WAITING,EXIT}
var state: int = STATES.INTRO

var speed = 0.0
var frameVar = 0.0
var starRotation = 0.0
var rotationTimer = 0.0
var spinningStars = []

# active is set to true when the player enters the ring
var active = false
# timer used for time to a room change
var timer = 0
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spinningStars = [%Star1,%Star2,%Star3,%Star4]
	speed = 0


func _process(delta):
	if active:
		# stop level timer (prevents time over)
		Global.timerActive = false
		# increase timer
		timer += delta
		if timer < 0.1 and timer+delta >= 0.1:
			active = false
			
			Global.music.stop()
			Global.drowning.stop()
			$Warp.play()
			# set next zone to current zone (this will reset when the stage is loaded back in)
			Global.nextZone = Global.main.lastScene
			
			# add ring to node memory so you can't farm the ring
			Global.nodeMemory.append(get_path())
			
			# fade to new scene
			Global.main.change_scene_to_file(load("res://Scene/SpecialStage/SpecialStageResult.tscn"),"WhiteOut","WhiteOut",1,true,false)
			# wait for scene to fade
			await Global.main.scene_faded
			queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		STATES.INTRO:
			speed = clampf(speed+delta,0.0,MAXSPEED)
			if speed >= MAXSPEED:
				state = STATES.WAITING
				$waitTime.start()
		STATES.WAITING:
			rotationTimer = wrapf(rotationTimer+delta,-2.0,2.0)
			starRotation += sign(delta*16)
		STATES.EXIT:
			speed -= delta
			if speed <= 0.0:
				queue_free()
	
	frameVar += delta*30
	
	# Calcutlate direction
	var yOffset = 16
	var direction = Vector2.DOWN
	var xOffset = 0.0
	for i in spinningStars.size():
		direction = Vector2.DOWN.rotated(
			deg_to_rad(
				fmod(xOffset + Global.globalTimer * 480,360)
				))
		xOffset += (360.0/spinningStars.size())
		spinningStars[i].position = (direction * yOffset * speed).round()
		spinningStars[i].position.y /= 3
		spinningStars[i].global_position += global_position
		spinningStars[i].frame = wrapi(
			round(frameVar),0,spinningStars[i].hframes)
	


func _on_timer_timeout() -> void:
	state = STATES.EXIT
	$Hitbox.monitoring = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	# check if not active and that the player is player 1
	if !active and body.playerControl == 1:
		active = true
		#body.visible = false
		body.movement = Vector2.ZERO
		# set players state to animation so nothing takes them out of it
		body.set_state(body.STATES.ANIMATION)
		# set player collision layer and mask to nothing to avoid collissions
		body.collision_layer = 0
		body.collision_mask = 0
		body.invTime = 0
		$Hitbox/CollisionShape2D.disabled = true
