extends Control

@export var bg_node:CanvasItem
@export var mid_node:CanvasItem
@export var front_node:CanvasItem

var lerp_weight = 0.05
var anime_scale = 5
var screen_center:Vector2

func _ready():
	screen_center = get_viewport().size / 2

func _process(_delta: float) -> void:
	var offset = (get_global_mouse_position() - screen_center).normalized() * 10
	lerp_position(bg_node, offset * -1)
	lerp_position(mid_node, offset * 1.5)
	lerp_position(front_node, offset * 2)

func lerp_position(p_node:Node, offset:Vector2):
	var target_pos = offset * anime_scale
	p_node.position = p_node.position.lerp(target_pos, lerp_weight)
	var viewport_size = get_viewport().size
	p_node.position.x = clampf(p_node.position.x, -viewport_size.x/4, viewport_size.x/4)
	p_node.position.y = clampf(p_node.position.y, -viewport_size.y/4, viewport_size.y/4)
