extends BossBase

# you can use these to control behaviour
var phase: int = 0

@onready var getPose: Array[Vector2] = [$LeftPoint.global_position,$RightPoint.global_position]
@onready var pump = $EggMobile/WaterPump
@onready var pipe = $PipeTexture
var currentPoint: int = 1

var pipe_extension = 0
var state_timer: float = 0

var targetPosition: Vector2 = Vector2.ZERO

func _ready() -> void:
	# move to the set currentPoint position before the boss starts (plus 128 pixels higher)
	global_position = getPose[currentPoint]
	# run laugh function for every time the player gets hit
	connect("hit_player",Callable(self,"do_laugh"))
	super()

func _process(delta: float) -> void:
	updateDirection()
	update_flashing(delta)

func _physics_process(delta: float) -> void:
	# move boss
	global_position += velocity*delta
	# check if alive
	if active and !defeated_flag:
		# boss phase
		match(phase):
			0: # intro
				#if flashTimer <= 0:
				set_animation("laugh") #laugh
				velocity = Vector2.ZERO
				hp = 8
				phase = 1
			1: # Pump Poison
				if pump and pipe:
					if pipe_extension < 128:
						pipe_extension += delta*256
					if pump.fluid_level > 4:
						phase += 1
						print("Track Player")
			2: # Track Player 1, dunk water
				if pump and pipe:
					if pipe_extension > 0:
						pipe_extension -= delta*256
						
					pass
			3: # Wait for Mega Mack to be destroyed
				pass
			4: # 
				pass
			8:
				pass
	
	set_pipe_extension(delta)
	super(delta)


func scrap(delta:float = 0.0) -> void:
	var deathTimer: float = 0.0
	# defeated animation timer (default time is 3 seconds)
	if defeated_flag:
		# flame jet (only visible when moving)
		$EggMobile/EggmobileFlame.visible = !(velocity.x == 0 or $EggMobile/EggmobileFlame.visible)
		# if above 0 then count down
		if deathTimer > 0:
			# count down
			deathTimer -= delta
			# if about to hit 1.5 seconds, set velocity downward
			if deathTimer > 1.5:
				if deathTimer-delta <= 1.5:
					set_animation("exploded",1.5)
					#velocity.y = 200
			# if above 0.5 seconds left, move the momentum upwards until it's about -200
			elif deathTimer > 0.5:
				if velocity.y > -200:
					velocity.y -= 100*delta
				# if the next step is going to be below 0.5 seconds then stop moving
				if deathTimer-delta <= 0.5:
					velocity.y = 0
			
			# start running away once timer hits 0
			if deathTimer <= 0:
				velocity = Vector2(200,-25)
				direction = 1
				#scale.x = -abs(scale.x)
				_mark_defeated()

func set_pipe_extension(delta: float) -> void:
	if pipe:
		var d0: float = 16 + pipe_extension
		$PipeTexture.size.y = d0
		if pipe_extension > 128:
			var d1: float = $PumpPosition.global_position.y
			var d2: float = $PipeTexture.global_position.y
			d1 -= 128*delta
			if d1 <= d2 and pump:
				pump.fluid_level += 1
				print(pump.fluid_level)
			d1 = wrapf(d1,d2,d2+d0)
			$PumpPosition.global_position.y = d1
		$PumpPosition.visible = (pipe_extension > 128)


func on_first_defeat() -> void:
	super()
	$PipeTexture.queue_free()
	$PumpPosition.queue_free()
	pipe = null
	if pump:
		var d0: Vector2 = pump.global_position
		pump.top_level = true
		pump.global_position = d0
		pump.velocity.x = -3*direction
		pump.velocity.y = -2
		pump.parent = null
