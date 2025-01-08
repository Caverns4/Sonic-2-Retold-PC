@tool
extends StaticBody2D

#Todo
@export_enum("Angled","Vertical") var type = 0

var flipsound = preload("res://Audio/SFX/Objects/CNZ_Flipper.wav")
var players = []
var direction = 0
var active = false
var frameTimer = 0.0

func _ready() -> void:
	if !Engine.is_editor_hint():
		direction = sign(scale.rotated(rotation).x)
	if type == 0:
		$VeritcalCollison.disabled = true
		$AngledCollision.disabled = false
		$VeritcalCollison.visible = false
		$Sprite2D.frame = 0
	else:
		$VeritcalCollison.disabled = false
		$AngledCollision.disabled = true
		$AngledCollision.visible = false
		$Sprite2D.frame = 4

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if type == 0:
			$VeritcalCollison.visible = false
			$Sprite2D.frame = 0
		else:
			$AngledCollision.visible = false
			$Sprite2D.frame = 4
	else:
		if type == 1:
			if active:
				frameTimer -= delta
				if frameTimer <= 0.0:
					$Sprite2D.frame = 4
					active = false
		else: # type == 0
			if active:
				frameTimer -= delta
				if frameTimer <= 0.0:
					$Sprite2D.frame = 0
					active = false
			else:
				for player in players:
					#TODO: Make this an Area2D instead
					if (player.global_position.x > global_position.x + 40 
					or player.global_position.x < global_position.x - 40
					or player.global_position.y > global_position.y + 16
					or player.global_position.y < global_position.y - 24):
						players.erase(player)
					else:
						if player.ground:
							var offsetDiff = direction*8 #Number of pixels from the "center"
							var height = round(
								((direction*player.global_position.x) - ((direction*global_position.x) - (offsetDiff*direction)))
								/4)
							print(height)
							if height > 0:
								active = true
								frameTimer = 0.1
								player.movement.y = 0 - (height * 120)
								player.movement.x = (height) * direction
								player.currentState = player.STATES.AIR
								player.animator.play("roll")
								Global.play_sound(flipsound)
								players.erase(player)
								$Sprite2D.frame = 1
						else:
							players.erase(player)
							player.controlObject = null
							player.translate = false
				


func physics_collision(player, hitVector):
	if type == 0:
		if hitVector.y > 0:
			player.controlObject = self
			players.append(player)
			#player.translate = true
	else:
		if player.ground and round(hitVector.y) == 0:
			player.currentState = player.STATES.ROLL
			player.animator.play("roll")
			player.movement.x = 0-(hitVector.x * 960)
			Global.play_sound(flipsound)
			active = true
			frameTimer = 0.2
			if hitVector.x > 0:
				$Sprite2D.frame = 3
			else:
				$Sprite2D.frame = 5
