extends Node2D

const MAXSPEED = 1.5

enum STATES{INTRO,WAITING,EXIT}
var state: int = STATES.INTRO

var speed: float = 0.0
var frameVar: float = 0.0
var starRotation: float = 0.0
var rotationTimer: float = 0.0
var spinningStars: Array = [Sprite2D]

# active is set to true when the player enters the ring
var active: bool = false
# timer used for time to a room change
var timer: float = 0
var player: Player2D = null

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
			
			SoundDriver.music.stop()
			$Warp.play()
			
			# Set up level memory so Sonic won't lose level progress.
			Global.save_level_data(player.respawnPosition)
			
			# fade to new scene
			Main.change_scene("res://Scene/SpecialStage/SpecialStage.tscn","WhiteOut",1.0,false)
			# wait for scene to fade
			await Main.scene_faded
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
		player = body
		#player.visible = false
		body.movement = Vector2.ZERO
		# set players state to animation so nothing takes them out of it
		body.set_state(body.STATES.ANIMATION)
		body.collision_layer = 0
		body.collision_mask = 0
		body.invTime = 0
		Main.can_pause = false
