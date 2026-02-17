class_name SliderPopUpMenu
extends GeneralPopUpMenu

## clamp for minimum and maximum sound volume
var clampSounds = [-40.0,6.0]
## how much to iterate through (take the total sum then divide it by how many steps we want)
@onready var soundStep = (abs(clampSounds[0])+abs(clampSounds[1]))/100.0

## The value this slider was initialized to
var initial_value: int = 0
## Minimum value of the slider
var min_slider_value: int = 0
## Maximum value of the slider
var max_slider_value: int = 100
## The name of the Slider
var title: String = ""

var sound_effect: AudioStreamPlayer = null

@onready var title_label: Label = $Panel/NinePatchRect/MenuOptions/Label
@onready var slider: HSlider = $Panel/NinePatchRect/MenuOptions/HSlider



func  _ready() -> void:
	SoundDriver.play_sound(sfx_select)
	title_label.text = title + str(int(initial_value)).lpad(3)
	slider.value = initial_value
	slider.max_value = max_slider_value

func activate_menu():
	$Panel/NinePatchRect/MenuOptions/HSlider.grab_focus()

func _on_h_slider_value_changed(value: float) -> void:
	title_label.text = title + str(int(value)).lpad(3)
	if sound_effect and !sound_effect.playing:
		sound_effect.play()
		var get_bus = sound_effect.bus
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(get_bus),
		clamp(clampSounds[0]+(value*soundStep),
		clampSounds[0],clampSounds[1]))

func _on_accept_button_pressed() -> void:
	close_menu(slider.value)
	SoundDriver.play_sound(sfx_confirm)


func _on_cancel_button_pressed() -> void:
	close_menu(initial_value)
	SoundDriver.play_sound(sfx_cancel)
