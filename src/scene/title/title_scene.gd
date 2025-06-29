extends "res://src/component/base_scene/base_scene.gd"

@onready var setting_popup = get_setting_popup()

func get_setting_popup():
	return $setting_popup


func _on_setting_btn_pressed() -> void:
	setting_popup.open()


func _on_exit_btn_pressed() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_start_btn_pressed() -> void:
	$level_popup.show()
	for ctrl in [$title_tex_rect, $start_btn, $setting_btn, $exit_btn]:
		ctrl.hide()


func _on_panel_gui_input(event:  InputEvent) -> void:
	var mouse_button := event as InputEventMouseButton
	if mouse_button != null && mouse_button.pressed && mouse_button.button_index == MOUSE_BUTTON_LEFT:
		$level_popup.hide()
		sound_bus.play_sound(preload("res://src/assets/se/cancel2.ogg"))
		for ctrl in [$title_tex_rect, $start_btn, $setting_btn, $exit_btn]:
			ctrl.show()
