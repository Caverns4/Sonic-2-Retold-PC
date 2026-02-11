extends StaticBody2D
var getCam = null

@onready var screenXSize = get_viewport_rect().size.x

var animal_inst = preload("res://Entities/Misc/Animal.tscn")
var animals = []
var timer = 180.0/60.0

enum STATE{IDLE,SPAWN_ANIMALS,WAIT,NULL}
var state: int = STATE.IDLE

func _ready() -> void:
	if Global.two_player_mode:
		queue_free()

func _physics_process(delta):
	match state:
		STATE.SPAWN_ANIMALS:
			_run_animal_timer(delta)
		STATE.WAIT:
			_update_animals_array()

func _run_animal_timer(delta: float):
	# every 8/60 steps spawn an animal in the animal ground with an alarm of 12/60
	if wrapf(timer,0,8.0/60.0) < wrapf(timer-delta,0,8.0/60.0):
		var animal_node = animal_inst.instantiate()
		# set animal sprite
		animal_node.animal = Global.animals[round(randf())]
		# deactivate animal to stop movement
		animal_node.active = false
		# random directions
		animal_node.forceDirection = false
		get_parent().add_child(animal_node)
		animals.append(animal_node)
		# set animal position, starting from -28 on the x position and increasing by 8 per animal
		animal_node.global_position = global_position+Vector2(randf_range(-20,20),0)
		# set alarms, starting at 12.0/60.0 (converting the original timer)
		animal_node.get_node("ActivationTimer").start(12.0/60.0)
		
		timer -= delta
		if timer < 0.0:
			state = STATE.WAIT

func _update_animals_array():
	for i in animals:
		if !is_instance_valid(i):
			animals.erase(i)
		
	if animals.size() == 0:
		state = STATE.NULL
		Global.emit_stage_clear()



func activate():
	# check if to clear level
	if !Global.stage_cleared:
		$Animator.play("Open")
		$Explode.play()
		Global.emit_await_stage_end()

		# Camera limit set
		for i in Global.players:
			i.limitLeft = global_position.x -screenXSize/2
			i.limitRight = global_position.x +(screenXSize/2)+64
		# set player camera limits
		for i in Global.players:
			# Camera limit set
			i.limitLeft = global_position.x -screenXSize/2
			i.limitRight = global_position.x +screenXSize/2
		state = STATE.SPAWN_ANIMALS


func spawn_animals():
	# create animals
	for i in range(8):
		var animal = animal_inst.instantiate()
		# set animal sprite
		animal.animal = Global.animals[round(randf())]
		# deactivate animal to stop movement
		animal.active = false
		# random directions
		animal.forceDirection = false
		get_parent().add_child(animal)
		animals.append(animal)
		# set animal position, starting from -28 on the x position and increasing by 8 per animal
		animal.global_position = global_position+Vector2(-28+(7*i),0)
		# set alarms, starting at 154.0/60.0 (converting the original timer) and counting down by 8.0/60.0 for each animal
		animal.get_node("ActivationTimer").start((154.0/60.0)-((8.0/60.0)*i))
	
	state = STATE.WAIT
	
