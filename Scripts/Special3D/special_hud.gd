extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.hud = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TopLeft/RingCountP1.text = str(min(Global.players[0].rings,999))
	if Global.players.size() > 1:
		$TopRight/RingCountP2.text = str(min(Global.players[1].rings,999))
