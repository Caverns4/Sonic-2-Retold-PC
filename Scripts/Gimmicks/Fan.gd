@tool
extends Area2D

#TODO: Horizonal Fans have different behavior than vertical fans, pretty much entirely

var players = []
@export var speed: float = 90.0 # default power
@export var isActive: bool = true
@export var touchActive: bool = false
@export var playSound: bool = true
@export var activeTime: float = 0.0 #if 0, never expire

var timer: float = 0.0
var getFrame: float = 0.0
var animSpeed: float = 0.0

var Bubble = preload("res://Entities/Misc/Bubbles.tscn")

func _ready():
	scale.x = max(1,scale.x)
	$fan.global_scale = Vector2(1,1)
	if $fan.texture != null:
		$fan.region_rect.size.x = $fan.texture.get_width()*round(scale.x)

func _process(delta):
	if Engine.is_editor_hint():
		scale.x = max(1,scale.x)
		$fan.global_scale = Vector2(1,1)
		if $fan.texture != null:
			$fan.region_rect.size.x = $fan.texture.get_width()*round(scale.x)
	# animate
	var goSpeed = 0.0
	if isActive:
		if !touchActive or players.size() > 0:
			if activeTime == 0:
				goSpeed = 30.0
			else:
				goSpeed = clampf(timer*30.0,0,30.0)
			# play fan sound
			if playSound and !Engine.is_editor_hint():
				if !$FanSound.playing:
					$FanSound.play()
		# end sound if playing
		elif $FanSound.playing:
				$FanSound.stop()
	# back up end sound
	elif $FanSound.playing:
			$FanSound.stop()
	
	animSpeed = lerp(animSpeed,goSpeed,delta*1.5)
	$fan.frame = getFrame
	getFrame = wrapf(getFrame+delta*animSpeed,0,$fan.hframes*$fan.vframes)



func _physics_process(delta):
	timer += delta
	timer = wrapf(timer,(0-activeTime),activeTime)
	if !Engine.is_editor_hint():
		# if any players are found in the array, if they're on the ground make them roll
		if players.size() > 0 and (activeTime == 0 or timer > 0.0):
			for i in players:
				if !i.controlObject and !i.translate:
					
					var force = Vector2(0,-30).rotated(global_rotation)
					i.movement += force
					#Only do this if the fan is pointing upward
					if force.y < 0:
						#i.movement.y = min(i.movement.y,90)
						i.movement.y = clamp(i.movement.y,-360,120)
						if i.ground and i.currentState != i.STATES.ROLL:
							i.disconect_from_floor()
						
					#Play floating animation if player is in midair
					if !i.ground:
						# force air state
						var setPlayerAnimation = "corkScrew"
						# water animation
						if i.water:
							setPlayerAnimation = "current"
						if i.currentState != i.STATES.ANIMATION or i.animator.current_animation != setPlayerAnimation:
							i.set_state(i.STATES.AIR)
							i.animator.play(setPlayerAnimation)
	


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
	(Global.waterLevel and Global.waterLevel < global_position.y)):
		var bub = Bubble.instantiate()
		bub.global_position = global_position+Vector2((16.0*abs(scale.x)-4.0)*randf_range(-1.0,1.0),-8.0*sign(scale.y))
		# choose between 2 bubble types, both cosmetic
		bub.bubbleType = int(round(randf()))
		# add to the speed of the bubbles
		bub.velocity.y -= speed*0.5
		bub.maxDistance = (global_position.y-(16*scale.y)+cos(Global.levelTime*4)*4)
		get_parent().add_child(bub)
