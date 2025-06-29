extends Control



@onready var sound_slider = get_sound_slider()
@onready var music_slider = get_music_slider()
@export var close_sound: AudioStream

func get_sound_slider() -> HSlider:
	return $panel/sound_slider

func get_music_slider() -> HSlider:
	return $panel/music_slider



func open():
	update_volume()
	
	grab_focus()
	show()

func close():
	save_volume()

	release_focus()
	hide()

	sound_bus.play_sound(close_sound)
	print(6)

func update_volume():
	sound_slider.value = volume_setting.get_group_volume(volume_setting.SOUND_GROUP)
	music_slider.value = volume_setting.get_group_volume(volume_setting.MUSIC_GROUP)

func save_volume():
	volume_setting.set_group_volume(volume_setting.SOUND_GROUP, sound_slider.value)
	volume_setting.set_group_volume(volume_setting.MUSIC_GROUP, music_slider.value)

func _on_close_btn_pressed() -> void:
	close()

func _on_apply_btn_pressed() -> void:
	close()
	
	volume_setting.set_group_volume(volume_setting.SOUND_GROUP, sound_slider.value)
	volume_setting.set_group_volume(volume_setting.MUSIC_GROUP, music_slider.value)


func _on_color_rect_gui_input(event: InputEvent) -> void:
	var mouse_button := event as InputEventMouseButton
	if mouse_button != null && mouse_button.pressed && mouse_button.button_index == MOUSE_BUTTON_LEFT:
		close()
