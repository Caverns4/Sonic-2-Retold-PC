@tool
extends StaticBody2D
@export var pieces = Vector2(2,2)
@export var SpriteTexture = preload("res://Graphics/Obstacles/Blocks/breakable_block.png")
var Piece = preload("res://Entities/Misc/BlockPiece.tscn")
@export var sound = preload("res://Audio/SFX/Gimmicks/s2br_Collapse.wav")
@export var score = true
@export var knockBack = true


func _ready() -> void:
	# Change platform shape
	$CollisionShape2D.shape.size.x = SpriteTexture.get_size().x
	$CollisionShape2D.shape.size.y = SpriteTexture.get_size().y
	# Updat Platform Sprite
	if Engine.is_editor_hint():
		# Change platform sprite texture
		$Sprite2D.texture = SpriteTexture
	else:
		# Change platform sprite texture
		$Sprite2D.texture = SpriteTexture

func _process(delta):
	if Engine.is_editor_hint():
		$Sprite2D.texture = SpriteTexture
		queue_redraw()

func physics_collision(body, hitVector):
	# check if physics object is coming down and check for a bit where the player isn't on floor
	if hitVector == Vector2.DOWN and body.get_collision_layer_value(20):
		# disable collision
		$CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		Global.play_sound(sound)
		
		# set player variables
		body.ground = false
		if knockBack:
			body.movement.y = -3*60
		else:
			body.movement.y = 3*60
		if score:
			Global.add_score(
				global_position,
				Global.SCORE_COMBO[min(Global.SCORE_COMBO.size()-1,body.enemyCounter)],
				Global.players.find(body))
		body.enemyCounter += 1
		
		# generate pieces of the block to scatter, use i and j to determine the velocity of each one
		# and set the settings for each piece to match up with the $Sprite2D node
		for i in range(pieces.x):
			for j in range (pieces.y):
				var piece = Piece.instantiate()
				
				piece.velocity = Vector2(
				(pieces.y-j)*lerp(-1,1,i/(pieces.x-1)),
				-pieces.y+j)*60
				
				var spriteWidth = $Sprite2D.texture.get_width()
				var spriteHeight = $Sprite2D.texture.get_height()
				if $Sprite2D.region_enabled:
					spriteWidth = $Sprite2D.region_rect.size.x
					spriteHeight = $Sprite2D.region_rect.size.y
				
				piece.global_position = global_position+Vector2(
				spriteWidth/4*lerp(-1,1,i/(pieces.x-1)),
				spriteHeight/4*lerp(-1,1,j/(pieces.y-1))
				)
				piece.texture = $Sprite2D.texture
				piece.z_index = z_index
				piece.region_rect = Rect2(
				Vector2((spriteWidth/pieces.x)*i,(spriteHeight/pieces.y)*j),
				Vector2(spriteWidth/pieces.x,spriteHeight/pieces.y))
				get_parent().add_child(piece)
				
	return true

func _draw():
	if Engine.is_editor_hint():
		#draw_texture(SpriteTexture,SpriteTexture.get_size()/2,Color.WHITE)
		draw_texture(SpriteTexture,-SpriteTexture.get_size()/2,Color.WHITE)
