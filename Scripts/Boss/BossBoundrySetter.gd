extends Area2D


@onready var screenSize: Vector2 = GlobalFunctions.get_screen_size()

@export_node_path var bossPath: NodePath

@export var keepLeftLocked: bool = true
@export var keepTopLocked: bool = true

@export var keepRightLocked: bool = true
@export var keepBottomLocked: bool = true

@export var lockLeft: bool = true
@export var lockTop: bool = true

@export var lockRight: bool = true
@export var lockBottom: bool = true


@export var ratchetScrollLeft: bool = false
@export var ratchetScrollTop: bool = false
@export var ratchetScrollRight: bool = false
@export var ratchetScrollBottom: bool = false

var bossActive: bool = false

signal boss_start()

func _ready() -> void:
	if Global.two_player_mode:
		queue_free()

func _on_BoundrySetter_body_entered(body: Player2D) -> void:
	if !Engine.is_editor_hint():
		$CollisionShape2D.set.call_deferred("disabled",true)
		# set boundry settings
		if !bossActive:
			# Check body has a camera variable
			if body.camera:
				var boss: BossBase = get_node_or_null(bossPath)
				if boss != null:
					bossActive = true
					# Check if set boundry is true, if it is then set the camera's boundries for each player
					for i: Player2D in Global.players:
						if lockLeft:
							i.limitLeft = max(global_position.x-screenSize.x/2,Global.hardBorderLeft)
							i.camera_limits_target[0] = i.limitLeft
						if lockTop:
							i.limitTop = max(global_position.y-screenSize.y/2,Global.hardBorderTop)
							i.camera_limits_target[1] = i.limitTop
						if lockRight:
							i.limitRight = min(global_position.x+screenSize.x/2,Global.hardBorderRight)
							i.camera_limits_target[2] = i.limitRight
						if lockBottom:
							i.limitBottom = min(global_position.y+screenSize.y/2,Global.hardBorderBottom)
							i.camera_limits_target[3] = i.limitBottom
						i.camera_shift_time = 0.0
					
					if !Global.players[0].is_super:
						SoundDriver.set_volume(-50)
						await SoundDriver.volume_set
						SoundDriver.set_volume(0,100)
					
					emit_signal("boss_start")
					if Global.hud:
						Global.hud.setup_boss_meter(boss)
					
					Global.fightingBoss = true
					SoundDriver.playNormalMusic()
					boss.active = true
					
					if boss.has_signal("boss_over"):
						boss.connect("boss_over",Callable(self,"boss_completed"))

func boss_completed() -> void:
	Global.fightingBoss = false
	SoundDriver.playNormalMusic()
	# set boundries for players
	for i in Global.players:
		if is_instance_valid(i):
			if !keepLeftLocked:
				i.limitLeft = Global.hardBorderLeft
				i.camera_limits_target[0] = i.limitLeft
			if !keepTopLocked:
				i.limitTop = Global.hardBorderTop
				i.camera_limits_target[1] = i.limitTop
			if !keepRightLocked:
				i.limitRight = Global.hardBorderRight
				i.camera_limits_target[2] = i.limitRight
			if !keepBottomLocked:
				i.limitBottom = Global.hardBorderBottom
				i.camera_limits_target[3] = i.limitBottom
			# set ratchetScrolling
			i.rachetScrollLeft = ratchetScrollLeft
			i.rachetScrollRight = ratchetScrollRight
