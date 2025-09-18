@tool
extends StaticBody2D

#Todo
@export_enum("Angled","Vertical") var type: int = 0

var flipsound: AudioStream = preload("res://Audio/SFX/Objects/CNZ_Flipper.wav")
var players: Array[Player2D] = []
var direction: int = 0
var just_used: bool = false
var frameTimer: float = 0.0

func _ready() -> void:
	if !Engine.is_editor_hint():
		direction = sign(scale.rotated(rotation).x)
	if type == 0:
		$VeritcalCollison.disabled = true
		$AngledCollision.disabled = false
		$VeritcalCollison.visible = false
		$Sprite2D.frame = 0
		$Area2D.monitoring = true
	else:
		$VeritcalCollison.disabled = false
		$AngledCollision.disabled = true
		$AngledCollision.visible = false
		$Sprite2D.frame = 4
		$Area2D.monitoring = false


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
			if just_used:
				frameTimer -= delta
				if frameTimer <= 0.0:
					$Sprite2D.frame = 4
					just_used = false
		else: # type == 0
			if just_used:
				frameTimer -= delta
				if frameTimer <= 0.0:
					$Sprite2D.frame = 0
					just_used = false
			else:
				var launch: bool = false
				for player in players:
					if player.ground:
						player.animator.play("roll")
						player.set_state(player.STATES.ANIMATION)
						player.set_hitbox(player.currentHitbox.ROLL,false)
						#player.movement.x = 60 * direction
						player.movement.x = 0
						player.global_position.x += (60*delta)*direction
						if player.jumpBuffer > 0.0:
							launch = true
							
				if launch:
					$Sprite2D.frame = 1
					SoundDriver.play_sound(flipsound)
					frameTimer = 0.1
					just_used = true
					for player in players:
						var offsetDiff = (player.global_position.x - global_position.x)*direction
						var height = offsetDiff/2
						if height > 0:
							height = clamp(height,8,16)
							player.angle = 0
							player.movement.y = 0 - (height * 60)
							player.movement.x = (height*15) * direction
							player.currentState = player.STATES.AIR
							player.animator.play("roll")
							player.controlObject = null
							player.allowTranslate = false
							players.erase(player)


func physics_collision(player, hitVector):
	if type == 0:
		if hitVector.y > 0:
			#player.controlObject = self
			player.set_state(player.STATES.ROLL)
			#players.append(player)
			#player.translate = true
	else:
		if player.ground and round(hitVector.y) == 0:
			player.set_state(player.STATES.ROLL)
			player.animator.play("roll")
			player.movement.x = 0-(hitVector.x * 960)
			SoundDriver.play_sound(flipsound)
			just_used = true
			frameTimer = 0.2
			if hitVector.x > 0:
				$Sprite2D.frame = 3
			else:
				$Sprite2D.frame = 5


func _on_area_2d_body_entered(body: Node2D) -> void:
	players.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	body.set_state(body.STATES.AIR)
	body.controlObject = null
	body.allowTranslate = false
	players.erase(body)
	
