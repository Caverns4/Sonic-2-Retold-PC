extends EnemyBase

@export_enum("Launch","Flying") var behavior = 0
@onready var animation = $AnimationPlayer
@onready var PlayerSensor = $PlayerSensor/Area2D
@onready var flame = $Balkerie/Fire

enum STATES{WAIT,LAUNCH,FLY}
var state = STATES.WAIT

func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true
	if behavior > 0:
		flame.visible = true
		animation.play("Fly")
		state = STATES.FLY

func _physics_process(_delta: float) -> void:
	match state:
		STATES.FLY:
			velocity = Vector2(-180,0)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Launch":
		animation.play("Fly")
		state = STATES.FLY
		flame.visible = true


func _on_area_2d_body_entered(_body: Node2D) -> void:
	PlayerSensor.queue_free()
	animation.play("Launch")
	velocity = Vector2(-60,-60)
