#============================================================
#    Input Utils
#============================================================
# - datetime: 2022-09-19 23:08:46
#============================================================
class_name InputUtil


##  是否点击了左键
##[br]
##[br][code]event[/code]  事件对象
##[br][code]pressed[/code]  是否按下
static func is_click_left(event: InputEvent, pressed := true) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT and event.pressed == pressed
	return false


##  鼠标是否正在移动
static func is_motion(event: InputEvent, button_mask : int = 0) -> bool:
	if button_mask == 0:
		return event is InputEventMouseMotion
	return event is InputEventMouseMotion and event.button_mask == button_mask


##  是否点击了右键
##[br]
##[br][code]event[/code]  事件对象
##[br][code]pressed[/code]  是否按下
static func is_click_right(event: InputEvent, pressed := true) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_RIGHT and event.pressed == pressed
	return false

##  是否点击了中键
##[br]
##[br][code]event[/code]  事件对象
static func is_click_middle(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed
	return false

##  是否双击
##[br]
##[br][code]event[/code]  事件对象
static func is_double_click(event: InputEvent):
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT and event.pressed and event.double_click
	return false


##  获取鼠标全局位置
static func get_global_position() -> Vector2:
	return DataUtil.get_meta_data("__InputUtil_get_global_position_node2D", 
		func(): 
			var node2d = Node2D.new()
			Engine.get_main_loop().root.add_child(node2d)
			return node2d
	).get_global_mouse_position()

