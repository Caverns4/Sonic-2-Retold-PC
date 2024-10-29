extends CharacterBody2D
var animType = 0 # 0 flap, 1 change on fall
@export_enum("Bird", "Squirrel",
"Rabbit", "Chicken",
"Penguin", "Seal",
"Pig", "Eagle",
"Mouse", "Monkey",
"Turtle", "Bear",
"Beaver","Fox")var animal = 0

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
var speed = 180
var gravity = 0.21875
var direction = -1
var forceDirection = true # set this to false for capsule logic
var active = true

func _ready():
	velocity.y = -4*60
	
	if !forceDirection:
		direction = randi() and 1
	if direction == 0:
		direction = -1
	$animals.scale.x = direction
	
	# set animal properties (animType is 0 by default)
	match(animal):
		1: # Squirrel
			$animals.region_rect.position.x = 72
			animType = 1
		2: # Rabbit
			$animals.region_rect.position.y = 96
			animType = 1
		3: # Chicken
			$animals.region_rect.position.y = 64
		4: # Penguin
			$animals.region_rect.position = Vector2(72,64)
			animType = 1
		5: # Seal
			$animals.region_rect.position.y = 0
			animType = 1
		6: # Pig
			$animals.region_rect.position = Vector2(72,0)
			animType = 1
		7: # Eagle
			$animals.region_rect.position = Vector2(72,160)
		8: # Mouse
			$animals.region_rect.position.y = 160
			animType = 1
		9: # Monkey
			$animals.region_rect.position = Vector2(72,128)
			animType = 1
		10: # Turtle
			$animals.region_rect.position = Vector2(72,96)
			animType = 1
		11: # Bear
			$animals.region_rect.position.y = 128
			animType = 1
		12: # Beaver
			$animals.region_rect.position.y = 192
			animType = 1
		13: # Fox
			$animals.region_rect.position = Vector2(72,192)
			animType = 1


func _physics_process(delta):
	# check if active, if not then stop processing physics
	if !active:
		return false
	
	# if on floor and falling then bounce
	velocity.y += gravity*60.0
	move_and_slide()
	
	if is_on_floor():
		speed = animalPhysics[animal].x*60
		bouncePower = animalPhysics[animal].y*60
		
		match(animal):
			0, 3, 7: # gravity bird types
				gravity = 0.09375
		
		velocity.y = 0-bouncePower
		velocity.x = speed*direction

func _process(delta):
	# animation code
	if (velocity.x != 0):
		match (animType):
			0: # flap
				animTime += delta*30
				if (animTime >= 1):
					animTime = 0
					$animals.frame = wrapi($animals.frame+1,1,3)
			1: # bounce
				if (velocity.y >= 0):
					$animals.frame = 2
				else:
					$animals.frame = 1


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# set active on time out (some spawning scenerios like a capsule sets a delay)
func _on_activation_timer_timeout() -> void:
	active = true
