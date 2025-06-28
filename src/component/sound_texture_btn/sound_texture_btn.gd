extends TextureButton

@export var click_sound:AudioStream
@export var hover_sound:AudioStream

func _pressed():
	if click_sound:
		sound_bus.play_sound(click_sound)

func _notification(p_what: int) -> void:
	if p_what == NOTIFICATION_MOUSE_ENTER:
		if hover_sound:
			sound_bus.play_sound(hover_sound)
