extends CharacterBody2D

@export_enum("Front","Back") var wheelType: String = "Front"
var anim = "Front_RESET"
var free = false
var parent = null

func _ready():
	if Global.TwoPlayer:
		queue_free()
	
	if wheelType == "Back":
		z_index = 0
	else:
		z_index = 2

func _physics_process(delta):
	var curParent = get_parent().parent
	if curParent and curParent.flashTimer > 0:
		$Flash.visible = !$Flash.visible
	else:
		$Flash.visible = false
	
	if !is_on_floor():
		#velocity.y += 9.8*delta
		velocity.y += (0.09375/GlobalFunctions.div_by_delta(delta))
	elif is_on_floor() and free:
		velocity.y = -100
	else:
		velocity.y = 0
	move_and_slide()
	$Flash.frame = $Sprite2D.frame
	$Flash.flip_h = $Sprite2D.flip_h

func updateAnim(xMove):
	if xMove < 0:
		$Sprite2D.flip_h = false
	elif xMove > 0:
		$Sprite2D.flip_h = true
	
	anim = wheelType
	if xMove != 0:
		anim += "_Drive"
	else:
		anim += "_RESET"
	
	$AnimationPlayer.play(anim)
