extends ColorRect

signal finished

@export var shrink_time:float = 0.6
@export var expand_delay_time:float = 0.5
@export var expand_time:float = 0.4

var playing := false : set = set_playing

var tween:Tween

# for test
#func _unhandled_input(p_event: InputEvent) -> void:
	#if p_event is InputEventMouseButton && p_event.button_index == MOUSE_BUTTON_LEFT:
		#if p_event.is_released():
			#play(get_global_mouse_position())

func play(p_globalPos:Vector2):
	if playing:
		playing = false
	
	playing = true
	var localPos = get_transform().affine_inverse() * p_globalPos
	material.set_shader_parameter("circle_size", 1.1)
	material.set_shader_parameter("circle_position", localPos / size)
	
	tween = create_tween()
	tween.tween_property(material, "shader_parameter/circle_size", -0.05, shrink_time)
	tween.tween_property(material, "shader_parameter/circle_size", 1.1, expand_time).set_delay(expand_delay_time)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	playing = false
	finished.emit()

func set_playing(p_value):
	if playing == p_value:
		return
	
	if playing:
		if tween:
			if tween.is_valid():
				tween.kill()
			tween = null
	
	playing = p_value
	visible = playing
