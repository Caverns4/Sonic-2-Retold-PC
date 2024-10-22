extends StaticBody2D

var pieces = Vector2(2,2)
var Piece = preload("res://Entities/Misc/BlockPiece.tscn")
@export var sound = preload("res://Audio/SFX/Gimmicks/Collapse.wav")
@export var score = true

@export_range (0,80) var targetYSize = 64
var currentHeight = 0
var activated = false
var players = []
var destroyed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !destroyed:
		if activated:
			currentHeight = min(currentHeight+(delta*96),targetYSize)
		else:
			currentHeight = max(currentHeight-(delta*64),0)
		var ySize:int = roundi(currentHeight)
		reposition_elements(ySize)

func reposition_elements(size: int):
	$PillarSprite.region_rect = Rect2(0,0,32,size)
	$PillarSprite.position.y = 0-16-size
	$TopSprite.position.y = 0-32-size
	$CollisionShape2D.position.y = 16-(size)

func physics_collision(body, hitVector):
	#if get_parent().get("activated") != null:
	if body.get("character") != null:
		if body.character == Global.CHARACTERS.KNUCKLES or (
			body.character == Global.CHARACTERS.SONIC and body.isSuper):
			destroyed = true
			body.movement.x *= (60 * body.direction)
			body.velocity = body.movement
			BreakPillar(body)
		if hitVector.y > 0.0 and body.ground:
			destroyed = true
			body.movement.y += 60
			#body.velocity.y = 200
			body.ground = false
			body.animator.current_animation = "roll"
			BreakPillar(body)

func BreakPillar(body):
	$CollisionShape2D.disabled = true
	$CollisionShape2D.queue_free()
	$PlayerCheck.queue_free()
	$TopSprite.visible = false
	$PillarSprite.visible = false
	Global.play_sound(sound)
	
	if score:
		Global.add_score(global_position,Global.SCORE_COMBO[min(Global.SCORE_COMBO.size()-1,body.enemyCounter)])
	body.enemyCounter += 1
	
	# generate pieces of the block to scatter, use i and j to determine the velocity of each one
	# and set the settings for each piece to match up with the $Sprite2D node
	
	var sprite = $TopSprite
	var pieces = Vector2(2,2)
	BreakIntoPieces(sprite,pieces)
	sprite = $PillarSprite
	var temp = max(round($PillarSprite.region_rect.size.y/16),1)
	pieces = Vector2(2,temp+1)
	BreakIntoPieces(sprite,pieces)
	
func BreakIntoPieces(sprite, pieces):
	for i in range(pieces.x):
		for j in range (pieces.y):
			var piece = Piece.instantiate()
			
			piece.velocity = Vector2(
			(pieces.y-j)*lerp(-1,1,i/(pieces.x-1)),
			-pieces.y+j)*60
			
			var spriteWidth = sprite.texture.get_width()
			var spriteHeight = sprite.texture.get_height()
			if sprite.region_enabled:
				spriteWidth = sprite.region_rect.size.x
				spriteHeight = sprite.region_rect.size.y
			
			piece.global_position = global_position+Vector2(
			spriteWidth/4*lerp(-1,1,i/(pieces.x-1)),
			spriteHeight/4*lerp(-1,1,j/(pieces.y-1))
			)
			piece.texture = sprite.texture
			piece.z_index = z_index
			piece.region_rect = Rect2(
			Vector2((spriteWidth/pieces.x)*i,(spriteHeight/pieces.y)*j),
			Vector2(spriteWidth/pieces.x,spriteHeight/pieces.y))
			get_parent().add_child(piece)
			sprite.queue_free()


func _on_player_check_body_entered(body: Node2D) -> void:
	players.append(body)
	activated = true


func _on_player_check_body_exited(body: Node2D) -> void:
	players.erase(body)
	if !players:
		activated = false
