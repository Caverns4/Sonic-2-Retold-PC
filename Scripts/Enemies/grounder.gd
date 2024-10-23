extends EnemyBase

#Two types of behavior.
#1: Move left and right until reaching a ledge.
#2: Hide in wall until player enters the area, then break through 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VisibleOnScreenEnabler2D.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
