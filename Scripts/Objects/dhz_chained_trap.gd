@tool
extends Node2D

@export var chain_links: int = 8
@export var sfx: AudioStream = preload("res://Audio/SFX/Objects/s2br_Spikes.wav")
@export_enum("Clockwise","Counter-Clockwise") var fall_direction = 0

var active:bool = false
var angle:float = 0
var children:Array[Node2D] = []

func _ready() -> void:
	if !Engine.is_editor_hint():
		fall_direction = (fall_direction*2)-1
		for i in chain_links:
			var node = $ChainLink.duplicate()
			add_child(node)
			children.append(node)
		$ChainLink.queue_free()
		$DHZSpikedPlatform.z_index += 1
		children.append($DHZSpikedPlatform)
		angle = fall_direction*90
		

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		$DHZSpikedPlatform.position.y = chain_links*16

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		if active:
			angle = move_toward(angle,0.0,delta*80)
		
		var chain_size: int = 0
		for node in children:
			node.position = Vector2(0,chain_size).rotated(deg_to_rad(angle))
			chain_size += 16

func _draw():
	if Engine.is_editor_hint():
		var temppos = Vector2(-8,-8)
		var previewpos = Vector2(-8,-8)
		var chan_img = $ChainLink.texture
		for i in chain_links:
			draw_texture(chan_img,temppos,Color(1,1,1,1))
			temppos.y += 16
			previewpos.x += 0-(16 * (fall_direction*2-1))
			draw_texture(chan_img,previewpos,Color(1,1,1,0.5))


func _on_area_2d_body_entered(body: Node2D) -> void:
	active = true
