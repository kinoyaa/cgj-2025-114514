extends "res://src/component/base_scene/base_scene.gd"

@onready var setting_popup = get_setting_popup()

func get_setting_popup():
	return $setting_popup


func _on_setting_btn_pressed() -> void:
	setting_popup.open()


func _on_exit_btn_pressed() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
