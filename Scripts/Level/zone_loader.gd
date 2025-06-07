extends CanvasLayer

var loaded = false

func _ready() -> void:
	Global.players.clear()
	Global.music.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !loaded:
		match clampi(Global.savedZoneID,0,Global.ZONES.size()+1):
			Global.ZONES.EMERALD_HILL:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/EmeraldHill1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/EmeraldHill2.tscn")
			Global.ZONES.HIDDEN_PALACE:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/Hidden Palace 1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/Hidden Palace 2.tscn")
			Global.ZONES.HILL_TOP:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/HillTop1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/HillTop2.tscn")
			Global.ZONES.CHEMICAL_PLANT:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/ChunkZone.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/ChemicalPlant2.tscn")
			Global.ZONES.OIL_OCEAN:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/BaseZone.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/BaseZoneAct2.tscn")
			Global.ZONES.NEO_GREEN_HILL:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/NeoGreenHill1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/NeoGreenHill2.tscn")
			Global.ZONES.METROPOLIS:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/Metropolis1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/Metropolis2.tscn")
					2:
						Global.nextZone = load("res://Scene/Zones/Metropolis3.tscn")
			Global.ZONES.DUST_HILL:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/DustHill1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/DustHill2.tscn")
			Global.ZONES.WOOD_GADGET:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/Wood1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/Wood2.tscn")
			Global.ZONES.CASINO_NIGHT:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/CasinoNight1New.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/CasinoNight2New.tscn")
			Global.ZONES.JEWEL_GROTTO:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/JewelGrotto1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/JewelGrotto2.tscn")
			Global.ZONES.WINTER:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/Winter1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/Winter2.tscn")
			Global.ZONES.SAND_SHOWER:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/SandShower1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/SandShower2.tscn")
			Global.ZONES.TROPICAL:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/Tropical1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/Tropical2.tscn")
			Global.ZONES.SKY_FORTRESS:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/SkyFortress1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/SkyFortress2.tscn")
			Global.ZONES.DEATH_EGG:
				match Global.savedActID:
					0:
						Global.nextZone = load("res://Scene/Zones/DeathEgg1.tscn")
					1:
						Global.nextZone = load("res://Scene/Zones/DeathEgg2.tscn")
			Global.ZONES.SPECIAL_STAGE:
					Global.savedZoneID = Global.ZONES.EMERALD_HILL
					Global.savedActID = 0
					Global.nextZone = load("res://Scene/SpecialStage/SpecialStage.tscn")
			_:
				Global.nextZone = load("res://Scene/Presentation/DemoCredits.tscn")
				#Global.nextZone = load("res://Scene/Zones/EmeraldHill1.tscn")
		#Load the Zone
		loaded = true
		Global.main.change_scene_to_file(Global.nextZone,"FadeOut","FadeOut",1)
