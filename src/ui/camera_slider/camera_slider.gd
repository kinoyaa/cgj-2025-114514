extends HSlider

@export var viewport:SubViewport

@export var left_action:StringName
@export var right_action:StringName
@export var up_action:StringName
@export var down_action:StringName

@export var move_speed:float = 100

var dir := Vector2i.ZERO

func _ready():
	update()

func _process(p_delta: float) -> void:
	if dir == Vector2i.ZERO:
		return
	
	var moveDist = move_speed * p_delta
	var camera:Camera2D = viewport.get_camera_2d()
	assert(camera)
	camera.position += dir * moveDist
	update()

func _unhandled_input(p_event: InputEvent) -> void:
	if !left_action.is_empty() && p_event.is_action(left_action):
		get_tree().root.set_input_as_handled()
		if p_event.is_released():
			dir.x += 1
		elif !p_event.is_echo():
			dir.x -= 1
	elif !right_action.is_empty() && p_event.is_action(right_action):
		get_tree().root.set_input_as_handled()
		if p_event.is_released():
			dir.x -= 1
		elif !p_event.is_echo():
			dir.x += 1
	elif !up_action.is_empty() && p_event.is_action(up_action):
		get_tree().root.set_input_as_handled()
		if p_event.is_released():
			dir.y += 1
		elif !p_event.is_echo():
			dir.y -= 1
	elif !down_action.is_empty() && p_event.is_action(down_action):
		get_tree().root.set_input_as_handled()
		if p_event.is_released():
			dir.y -= 1
		elif !p_event.is_echo():
			dir.y += 1

func _value_changed(p_value: float) -> void:
	var camera:Camera2D = viewport.get_camera_2d()
	assert(camera)
	
	if camera.anchor_mode == Camera2D.ANCHOR_MODE_DRAG_CENTER:
		var vpW = viewport.size.x / camera.zoom.x
		camera.position.x = value - camera.offset.x + vpW / 2
	else:
		camera.position.x = value - camera.offset.x

func update():
	var camera:Camera2D = viewport.get_camera_2d()
	assert(camera)
	
	var vpW = viewport.size.x / camera.zoom.x
	max_value = camera.limit_right - camera.limit_left - vpW
	set_value_no_signal(camera.get_target_position().x)
