extends Control

@export var bg_node:CanvasItem
@export var mid_node:CanvasItem
@export var front_node:CanvasItem

var lerp_weight = 0.1
var anime_scale = 5

## 获取的加速度值
var vec2gravity

func _process(_delta: float) -> void:
	var mousePos = get_global_mouse_position()
	mousePos.x = clampf(mousePos.x, 0.0, size.x)
	mousePos.y = clampf(mousePos.y, 0.0, size.y)
	vec2gravity = Vector2(remap(mousePos.x, 0, size.x, -10, 10), remap(mousePos.y, 0, size.y, -10, 10))
	lerp_position(bg_node,-2)
	lerp_position(mid_node,-5)
	lerp_position(front_node,-3)

func lerp_position(p_node:Node, p_value:float):
	p_node.position = p_node.position.lerp(vec2gravity * p_value * anime_scale, lerp_weight)
	p_node.position.x = clampf(p_node.position.x, -320, 320)
	p_node.position.y = clampf(p_node.position.x, -180, 180)
