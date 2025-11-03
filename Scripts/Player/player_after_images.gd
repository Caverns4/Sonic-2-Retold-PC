extends Node

const NUM_SPRITES: int = 3
const TIME_BETWEEN: float = 0.0667

## Array of sprites.
var sprites: Array[Sprite2D] = []
## Flag set. 
var active: bool = false
## timer before a new frame is printed.
var sprite_timer: float = TIME_BETWEEN

@onready var player: Player2D = get_parent()

func _ready() -> void:
	call_deferred("_check_character")
	var parent_node: Node = player.get_parent()
	for i in NUM_SPRITES:
		var sprite: Sprite2D = Sprite2D.new()
		parent_node.call_deferred("add_child",sprite)
		sprites.append(sprite)
	player.turned_super.connect(activate)

func _check_character():
	if player.character != Global.CHARACTERS.SONIC:
		for i in sprites:
			i.queue_free()
		queue_free()

func activate():
	active = true

func _physics_process(_delta: float) -> void:
	if active:
		if !player.isSuper:
			active = false
			for i:Sprite2D in sprites:
				i.visible = false
			return
		sprite_timer -= _delta
		update_transparency()
		if sprite_timer <= 0.0:
			sprite_timer = TIME_BETWEEN
			copySprite()

func update_transparency():
	var mod_time = NUM_SPRITES
	var source = player.sprite
	for i:Sprite2D in sprites:
		i.visible = (fmod(round(Global.levelTime*60),mod_time) == 0)
		mod_time -= 1
		i.frame = source.frame
		i.global_rotation = source.global_rotation
		i.flip_h = source.flip_h
		i.flip_v = source.flip_v

func copySprite():
	var source = player.sprite
	var dest = sprites.pop_front()
	dest.texture = source.texture
	dest.hframes = source.hframes
	dest.vframes = source.vframes
	dest.frame = source.frame
	dest.offset = source.offset
	dest.global_position = source.global_position
	dest.material = source.material
	dest.z_index = source.z_index-1
	sprites.push_back(dest)
