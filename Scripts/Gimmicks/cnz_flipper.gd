extends StaticBody2D

#Todo
@export_enum("Angled","Vertical") var type = 0

var players =[]

func _ready() -> void:
	if type == 0:
		$VeritcalCollison.disabled = true
		$VeritcalCollison.visible = false
		$Sprite2D.frame = 0
	else:
		$AngledCollision.disabled = true
		$AngledCollision.visible = false
		$Sprite2D.frame = 4

func _physics_process(delta: float) -> void:
	for player in players:
		if !player.ground:
			player.controlObject = null
			players.erase(player)
			print("Fall")


func physics_collision(player, hitVector):
	player.controlObject = self
	players.append(player)
