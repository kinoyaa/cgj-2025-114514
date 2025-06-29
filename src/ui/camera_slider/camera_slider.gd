extends HSlider

@export var viewport:SubViewport

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
