@tool
extends CharacterBody2D

var animType = 0 # 0 flap, 1 change on fall
@export_enum("Bird", "Squirrel",
"Rabbit", "Chicken",
"Penguin", "Seal",
"Pig", "Eagle",
"Mouse", "Monkey",
"Turtle", "Bear",
"Beaver","Fox")var animal = 0

@export_enum("In place","right","left") var behavior = 0

@export var blockMovement = false

var animalPhysics = [
# (Bird)
Vector2(3.0,4.0),
# (Squirrel)
Vector2(2.5,3.5),
# (Rabbit)
Vector2(2.0,4.0),
# (Chicken)
Vector2(2.0,3.0),
# (Penguin)
Vector2(1.5,3.0),
# (Seal)
Vector2(1.25,1.5),
# (Pig)
Vector2(1.75,3.0),
# (Eagle)
Vector2(2.5,3.0),
# (Mouse)
Vector2(2.0,3.0),
# (Monkey)
Vector2(2.75,3.0),
# (Turtle)
Vector2(1.25,2.0),
# (Bear)
Vector2(2.0,3.0),
# (Beaver)
Vector2(2.0,3.0),
# (Fox)
Vector2(2.0,4.0),
]

var animTime = 0
var bouncePower = 300

func _ready():
	SetupAnimalArt()

func _physics_process(delta: float):
	if Engine.is_editor_hint():
		SetupAnimalArt()
	else:
		if !blockMovement:
			if !is_on_floor():
				velocity += get_gravity()*delta
			else:
				bouncePower = animalPhysics[animal].y*60
				velocity.y = 0-bouncePower
			move_and_slide()


func SetupAnimalArt():
	# set animal properties (animType is 0 by default)
	match(animal):
		0: #Bird
			$animals.region_rect.position = Vector2(0,32)
			animType = 0
		1: # Squirrel
			$animals.region_rect.position = Vector2(72,32)
			animType = 1
		2: # Rabbit
			$animals.region_rect.position =  Vector2(0,96)
			animType = 1
		3: # Chicken
			$animals.region_rect.position = Vector2(0,64)
			animType = 0
		4: # Penguin
			$animals.region_rect.position = Vector2(72,64)
			animType = 1
		5: # Seal
			$animals.region_rect.position = Vector2.ZERO
			animType = 1
		6: # Pig
			$animals.region_rect.position = Vector2(72,0)
			animType = 1
		7: # Eagle
			$animals.region_rect.position = Vector2(72,160)
			animType = 0
		8: # Mouse
			$animals.region_rect.position = Vector2(0,160)
			animType = 1
		9: # Monkey
			$animals.region_rect.position = Vector2(72,128)
			animType = 1
		10: # Turtle
			$animals.region_rect.position = Vector2(72,96)
			animType = 1
		11: # Bear
			$animals.region_rect.position = Vector2(0,128)
			animType = 1
		12: # Beaver
			$animals.region_rect.position = Vector2(0,192)
			animType = 1
		13: # Fox
			$animals.region_rect.position = Vector2(72,192)
			animType = 1
