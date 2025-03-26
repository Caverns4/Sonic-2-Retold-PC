extends StaticBody2D

@export var shiftTimer = 0.00
@onready var start = position
@onready var shiftPoint = position+(Vector2.DOWN*scale.sign()).rotated(rotation)*32
var sunk = false
var sunkShift = 0

func _ready():
	
	if !is_equal_approx(shiftTimer,0):
		$ShiftTimer.start(abs(shiftTimer))
	else:
		set_physics_process(false)

func _physics_process(delta):
	position = lerp(start,shiftPoint,sunkShift)
	sunkShift += (1.0-int(sunk)*2.0)*delta*16
	sunkShift = clamp(sunkShift,0,1)
	$HitBox.disabled = !sunk

# Collision check (this is where the player gets hurt, OW!)
func physics_collision(body, hitVector):
	if hitVector.is_equal_approx((Vector2.DOWN*scale.sign()).rotated(deg_to_rad(snapped(rotation_degrees,90)))):
		if body.character == Global.CHARACTERS.MIGHTY and body.curled:
			body.disconect_from_floor()
			body.global_position -= Vector2(ceil(hitVector.x),ceil(hitVector.y))*8
			body.curled = false
			body.abilityUsed = true
			body.sfx[4].play()
			body.movement.y = -3.5*60
			body.bounceReaction = 0
			body.animator.play("rebound")
			body.set_state(body.STATES.AIR)
		else:
			body.hit_player(global_position)
		#return true


func _on_ShiftTimer_timeout():
	if $VisibleOnScreenEnabler2D.is_on_screen():
		$sfxSpikeShift.play()
	sunk = !sunk
