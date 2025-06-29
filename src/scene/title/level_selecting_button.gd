extends TextureButton

@export var action: PackedScene = null

func _pressed() -> void:
	get_tree().change_scene_to_packed(action)
