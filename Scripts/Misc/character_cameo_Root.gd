@tool
extends Node2D

const WAIT_TIME = 2.0
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export_enum("Ring","Speed Shoes","Invincibility",
"Shield","Elec Shield","Fire Shield",
"Bubble Shield","Super","Teleport",
"Boost","Eggman","?",
"Extra Life","Tails Life") var present: int = 0
@export var characterTexture: Texture2D = preload("res://Graphics/Misc/Kris.png")

#Object state controllers
enum STATES{IDLE,THROW,JUMP}
var state: STATES = STATES.IDLE
var stateTimer: float = WAIT_TIME
var direction: int = -1
var active: bool = false

var players: Array[Player2D] = [] # targets in the sensor area

#Object projectile Controls
var drop: PackedScene = preload("res://Entities/Items/Monitor.tscn")

@onready var sprite: Sprite2D = $CharacterBody2D/CharacterSprite
@onready var character: CharacterBody2D = $CharacterBody2D

func _ready() -> void:
	if characterTexture:
		sprite.texture = characterTexture


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if (active or state > STATES.IDLE) and stateTimer > 0.0:
		stateTimer -= delta
	
	match state:
		STATES.IDLE:
			sprite.flip_h = UpdateLookDirection()
			if stateTimer <- 0.0:
				state = STATES.THROW
				sprite.frame = 1
				stateTimer = WAIT_TIME/2
				ThrowGift()
		STATES.THROW:
			sprite.flip_h = UpdateLookDirection()
			if stateTimer <- 0.0:
				state = STATES.JUMP
				sprite.frame = 2
				sprite.z_index = 20
				character.collision_mask = 0
				character.velocity.y = JUMP_VELOCITY
				character.velocity.x = SPEED*direction
		#JUMP has no qualifiers
	UpdateCharacterMotion(delta)
	# Delete self if way out of bounds
	if character.global_position.y > 4096:
		queue_free()

func UpdateCharacterMotion(delta: float) -> void:
	if character.is_on_floor():
		character.velocity.y = clampf(character.velocity.y,-3200,0)
	else:
		character.velocity += character.get_gravity() * delta
	character.move_and_slide()

func UpdateLookDirection() -> bool:
	direction = sign(global_position.x - Global.players[0].global_position.x)
	return direction < 0

func ThrowGift() -> void:
	var droppedItem: Node2D = drop.instantiate()
	get_parent().add_child(droppedItem)
	# set position with offset
	droppedItem.global_position = global_position
	droppedItem.physics = true
	droppedItem.item = present
	droppedItem.FrameUpdate()
	droppedItem.velocity.x = 0-60*direction
	droppedItem.yspeed = 0-SPEED


func _on_player_checker_body_entered(body: Node2D) -> void:
	players.append(body)
	if body == Global.players[0]:
		active = true


func _on_player_checker_body_exited(body: Node2D) -> void:
	players.erase(body)
	if body == Global.players[0]:
		active = false
		if state == STATES.IDLE:
			stateTimer = WAIT_TIME
