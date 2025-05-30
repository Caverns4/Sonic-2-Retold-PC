extends EnemyBase

func  _ready() -> void:
	super()
	$VisibleOnScreenEnabler2D.queue_free()
	process_mode = Node.PROCESS_MODE_PAUSABLE
