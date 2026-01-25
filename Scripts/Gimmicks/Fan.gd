#@tool
extends Area2D

var players = []
@export var isActive: bool = true
@export var touchActive: bool = false
@export var playSound: bool = true
@export var activeTime: float = 0.0 #if 0, never expire

const FORCE_AMOUNT  = 96

var timer: float = 0.0
var getFrame: float = 0.0
var animSpeed: float = 0.0
var pushPlayers: bool = true

var Bubble = preload("res://Entities/Misc/Bubbles.tscn")
enum DIRECTIONS{LEFT,VERTICAL,RIGHT}
var direction = 0
var names = ["Left","Vertical","Right"]

func _ready():
	if !Engine.is_editor_hint():
		var test = Vector2.UP.rotated(global_rotation)
		test.x = roundi(test.x)
		direction = sign(test.x)+1 as DIRECTIONS

	$fan.global_scale = Vector2(1,1)
	if $fan.texture != null:
		$fan.region_rect.size.x = $fan.texture.get_width()*round(scale.x)

func _process(delta):
	#if Engine.is_editor_hint():
	#	if $fan.texture != null:
	#		$fan.region_rect.size.x = $fan.texture.get_width()*round(scale.x)
	#	# No need to cotinue running the rest if we are in hint mode
	#	return
	# animate
	var goSpeed = 0.0
	if !touchActive or players.size() > 0:
		if activeTime == 0:
			goSpeed = 30.0
		else:
			goSpeed = clampf(timer*30.0,0,30.0)
		# play fan sound
		if playSound and !$FanSound.playing:
			$FanSound.play()
	# end sound if playing
	elif $FanSound.playing:
		$FanSound.stop()
	
	animSpeed = lerp(animSpeed,goSpeed,delta*1.5)
	$fan.frame = getFrame
	getFrame = wrapf(getFrame+delta*animSpeed,0,$fan.hframes*$fan.vframes)


func _physics_process(delta):
	#if Engine.is_editor_hint():
	#	return
	if !touchActive:
		timer += delta
		timer = wrapf(timer,-activeTime,activeTime)
	
	if animSpeed > 10 and !pushPlayers:
		pushPlayers = true
	elif animSpeed < 10 and pushPlayers:
		pushPlayers = false
	
	match direction:
		#Veritcal Fans
		DIRECTIONS.VERTICAL:
			for i in players:
				if pushPlayers and (!i.controlObject and !i.allowTranslate):
					i.movement.y += -30
					i.movement.y = clamp(i.movement.y,-240,120)
					if i.ground:
						i.disconect_from_floor()
						# force air state
					var setPlayerAnimation = "corkScrew"
					# water animation
					if i.is_in_water:
						setPlayerAnimation = "current"
					if i.currentState != i.STATES.ANIMATION or i.animator.current_animation != setPlayerAnimation:
						i.set_state(i.STATES.AIR)
						i.animator.play(setPlayerAnimation)
		#Horizonal Fans
		_:
			for i in players:
				#If the fan is active, the player is not externally controlled,
				#and the player is not rolling on the ground.
				if pushPlayers and (
				!i.controlObject and !i.allowTranslate) and !(
				i.ground and i.currentState == i.STATES.ROLL
				):
					var x_diff = (0-sign(direction-1))*(
					i.global_position.x - global_position.x)
					# calculate force
					var fan_force = floor(x_diff)
					if x_diff < 0:
						#Behind the fan
						fan_force = -(fan_force -1)*2
					#Final Position Calc
					fan_force = fan_force+FORCE_AMOUNT
					fan_force = (256 - fan_force)/16
					if (direction-1) < 0:
						fan_force = 0-fan_force
					i.global_position.x += fan_force


func _on_body_entered(body):
	if !players.has(body):
		players.append(body)

func _on_body_exited(body):
	if players.has(body):
		body.set_state(body.STATES.NORMAL)
		players.erase(body)

func activate():
	isActive = true

func deactivate():
	isActive = false

func activate_touch_active():
	touchActive = true

func deactivate_touch_active():
	touchActive = false

# generate bubbles
func _on_bubble_timer_timeout():
	if (isActive and (!touchActive or players.size() > 0) and
	(Global.waterLevel > 0 and Global.waterLevel < global_position.y)):
		var bub = Bubble.instantiate()
		bub.global_position = global_position+Vector2((16.0*abs(scale.x)-4.0)*randf_range(-1.0,1.0),-8.0*sign(scale.y))
		# choose between 2 bubble types, both cosmetic
		bub.bubbleType = int(round(randf()))
		# add to the speed of the bubbles
		bub.velocity.y -= 60*0.5
		bub.maxDistance = (global_position.y-(16*scale.y)+cos(Global.levelTime*4)*4)
		get_parent().add_child(bub)
