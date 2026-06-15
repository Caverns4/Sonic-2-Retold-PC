extends StaticBody2D

const DELAY_TIME: float = 4.0

@export var starting_delay: float = 0.0

enum STATE{HIDDEN,READY}
var state: STATE = STATE.HIDDEN 
var state_time: Timer = Timer.new()

@onready var plat_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	state_time.one_shot = true
	add_child(state_time)
	state_time.start(DELAY_TIME+starting_delay)
	state_time.timeout.connect(_on_stat_timer_timeout)

func _on_stat_timer_timeout() -> void:
	if state == STATE.HIDDEN:
		state = STATE.READY
		plat_sprite.play("pop-in")
		await plat_sprite.animation_finished
		set_collision_layer_value(1,true)
		plat_sprite.play("ready")
		state_time.start(DELAY_TIME)
	else:
		state = STATE.HIDDEN
		plat_sprite.play("pop-out")
		set_collision_layer_value(1,false)
		state_time.start(DELAY_TIME)
