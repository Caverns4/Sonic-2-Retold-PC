@tool
extends StaticBody2D
@export var SpriteTexture = preload("res://Graphics/Obstacles/BreakFloors/HTZ_BreakableFloor1.png")
@export var pieces = Vector2(2,1)
var Piece = preload("res://Entities/Misc/BlockPiece.tscn")
@export var sound = preload("res://Audio/SFX/Gimmicks/Collapse.wav")
@export_enum("Standard","Fragile") var type = 0

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
	# check hit is either left or right
	if hitVector == Vector2.DOWN:
		# verify if rolling or knuckles
		if ((body.animator.current_animation == "roll"
		and (body.currentState == body.STATES.ROLL)
		and body.ground) and body.movement.x > 200 and body.angle !=0) or (
		(body.animator.current_animation == "roll") and type == 1
		):
			# print(body.movement)
			# disable physics altering masks
			set_collision_layer_value(16,false)
			set_collision_layer_value(14,false)
			set_collision_mask_value(14,false)
			# give frame buffer
			await get_tree().process_frame
			$CollisionShape2D.disabled = true
			$Sprite2D.visible = false
			Global.play_sound(sound)
			body.velocity.x = body.velocity.x*0.8
			body.movement.x = body.movement.x*0.8
			
			if type > 0:
				body.movement.y = 200
				body.velocity.y = 200
				body.ground = false
				body.animator.current_animation = "roll"
			
			# generate brekable pieces depending on the pieces vector
			for i in range(pieces.x):
				for j in range (pieces.y):
					var piece = Piece.instantiate()
					
					piece.velocity = Vector2(
					lerp(1,2,i/(max(1,pieces.x-1)))*hitVector.x*(4),
					-pieces.y+j)*60
					
					var spriteWidth = $Sprite2D.texture.get_width()
					var spriteHeight = $Sprite2D.texture.get_height()
					if $Sprite2D.region_enabled:
						spriteWidth = $Sprite2D.region_rect.size.x
						spriteHeight = $Sprite2D.region_rect.size.y
					
					piece.global_position = global_position+Vector2(
					spriteWidth/4*lerp(-1,1,i/(max(1,pieces.x-1))),
					spriteHeight/4*lerp(-1,1,j/(max(1,pieces.y-1)))
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
