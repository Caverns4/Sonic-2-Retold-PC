@tool
extends StaticBody2D

## The time in seconds before the spikes extend/retract
@export var shiftTimer: float = 0.00
## The number of pairs of Spikes. 
@export_range (1,16) var count: int = 2

@onready var start = position
@onready var shiftPoint = position+(Vector2.DOWN*scale.sign()).rotated(rotation)*32
var sunk = false
var sunkShift = 0

func _ready():
	if !Engine.is_editor_hint():
		$VisibleOnScreenEnabler2D.visible = true
		if abs(global_rotation_degrees) > 10:
			set_collision_layer_value(4,true)
	
		if !is_equal_approx(shiftTimer,0):
			$ShiftTimer.start(abs(shiftTimer))
		else:
			set_physics_process(false)
	
	#$Spike.set_region_rect(Rect2(0,32,count*16,32))
	$TextureRect.size.x = count*16
	$TextureRect.position.x=0-($TextureRect.size.x/2)
	$HitBox.scale.x = count
	$VisibleOnScreenEnabler2D.scale.x = count

func _physics_process(delta):
	if Engine.is_editor_hint():
		#$Spike.set_region_rect(Rect2(0,32,count*16,32))
		$TextureRect.size.x = count*16
		$TextureRect.position.x=0-($TextureRect.size.x/2)
		$HitBox.scale.x = count
		$VisibleOnScreenEnabler2D.scale.x = count
	else:
		position = lerp(start,shiftPoint,sunkShift)
		sunkShift += (1.0-int(sunk)*2.0)*delta*16
		sunkShift = clamp(sunkShift,0,1)
		$HitBox.disabled = !sunk
	

# Collision check (this is where the player gets hurt, OW!)
func physics_collision(body, hitVector):
	if hitVector.is_equal_approx((Vector2.DOWN*scale.sign()).rotated(deg_to_rad(snapped(rotation_degrees,90)))):
		if body.character == Global.CHARACTERS.MIGHTY and (
			body.animator.current_animation == "drop" or 
			body.animator.current_animation == "roll"):
			body.disconect_from_floor()
			body.global_position -= Vector2(ceil(hitVector.x),ceil(hitVector.y))*8
			body.curled = false
			body.abilityUsed = true
			body.sfx[4].play()
			body.movement = (hitVector*-1)*3.5*60
			
			body.bounceReaction = 0
			body.animator.play("rebound")
			body.set_state(body.STATES.AIR)
		else:
			body.hit_player(global_position,0,4)


func _on_ShiftTimer_timeout():
	if $VisibleOnScreenEnabler2D.is_on_screen():
		$sfxSpikeShift.play()
	sunk = !sunk
