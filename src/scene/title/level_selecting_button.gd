extends TextureButton

@export var action: PackedScene = null

func _ready() -> void:
	mouse_entered.connect(
		func():
			sound_bus.play_sound(load("res://src/assets/se/cursor.ogg"))
	)

func _pressed() -> void:
	if action:
		get_tree().change_scene_to_packed(action)
		sound_bus.play_sound(load("res://src/assets/se/confirm.ogg"))
