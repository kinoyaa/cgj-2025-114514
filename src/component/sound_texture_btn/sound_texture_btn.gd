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
var t
func _ready() -> void:
	get_child(0).scale.x = 0.000001
	mouse_entered.connect(
		func():
			t = create_tween()
			t.tween_property(get_child(0),"scale:x",1.,0.3)\
				.set_trans(Tween.TRANS_CUBIC)\
				.set_ease(Tween.EASE_IN_OUT)
	)
	mouse_exited.connect(
		func():
			t = create_tween()
			t.tween_property(get_child(0),"scale:x",0.000001,0.3)\
				.set_trans(Tween.TRANS_CUBIC)\
				.set_ease(Tween.EASE_IN_OUT)
	)
