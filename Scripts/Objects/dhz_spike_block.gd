extends Node2D

@export var slide_distance: int = -128

var players: Array = []
var active: bool = false
var motionScale = 0.0
var slide_position: float = 0

func _ready() -> void:
	$VisibleOnScreenNotifier2D.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !active:
		for i in players:
			if i.ground:
				active = true
	else:
		
		#motionScale -= (64*delta)
		#var getPos = Vector2(motionScale,0.0)
		#print(getPos)
		#if abs(motionScale) > abs(slide_distance):
		#	motionScale = slide_distance
			
		slide_position = move_toward(slide_position,slide_distance,delta*64)
		var getPos = Vector2(slide_position,0)
		$DHZ_SpikeBlock.position = (getPos).round()
		
		if !$VisibleOnScreenNotifier2D.is_on_screen():
			$DHZ_SpikeBlock.position = Vector2.ZERO
			slide_position = 0
			active = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	players.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	players.erase(body)
