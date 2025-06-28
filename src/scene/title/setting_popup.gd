extends Control



@onready var sound_slider = get_sound_slider()
@onready var music_slider = get_music_slider()

func get_sound_slider() -> HSlider:
	return $panel/sound_slider

func get_music_slider() -> HSlider:
	return $panel/music_slider



func open():
	update_volume()
	
	grab_focus()
	show()

func close():
	release_focus()
	hide()

func update_volume():
	sound_slider.value = volume_setting.get_group_volume(volume_setting.SOUND_GROUP)
	music_slider.value = volume_setting.get_group_volume(volume_setting.MUSIC_GROUP)

func _on_close_btn_pressed() -> void:
	close()

func _on_apply_btn_pressed() -> void:
	close()
	
	volume_setting.set_group_volume(volume_setting.SOUND_GROUP, sound_slider.value)
	volume_setting.set_group_volume(volume_setting.MUSIC_GROUP, music_slider.value)
