extends CanvasLayer

signal finished

@export var shrink_time:float = 0.6
@export var expand_delay_time:float = 0.5
@export var expand_time:float = 0.4
@export var target_scene:Node

@export var color_rect:ColorRect

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
	var localPos = color_rect.get_transform().affine_inverse() * p_globalPos
	color_rect.material.set_shader_parameter("circle_size", 1.1)
	color_rect.material.set_shader_parameter("circle_position", localPos / color_rect.size)
	
	tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/circle_size", -0.05, shrink_time)
	tween.step_finished.connect(_on_tween_step_finished)
	
	tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/circle_size", 1.1, expand_time).set_delay(expand_delay_time)
	tween.finished.connect(_on_tween_finished)

func _on_tween_step_finished():
	tween.step_finished.disconnect(_on_tween_step_finished)
	if target_scene:
		var prevScene = get_tree().current_scene
		get_tree().root.remove_child(prevScene)
		
		target_scene.tree_entered.connect(_on_current_scene_tree_entered, CONNECT_ONE_SHOT)
		get_tree().root.add_child(target_scene)
		get_tree().root.update_mouse_cursor_state()

func _on_current_scene_tree_entered():
	get_tree().current_scene = target_scene

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
