extends BossBase

@export var eggman: CutsceneEggman = null

func _ready() -> void:
	super()
	if eggman:
		await eggman.ready
		eggman.set_facing_direction(true)

func _process(_delta: float) -> void:
	pass


func on_first_defeat() -> void:
	super()
	$SmokeTimer.start(0.01667*7)
	eggman.target_animation = "Fear"
