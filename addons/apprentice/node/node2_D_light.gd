#============================================================
#    Node 2d Light
#============================================================
# - datetime: 2023-02-13 09:53:29
#============================================================
## 设置 Node2D 节点的 self_modulate 属性的亮度
@tool
extends Node2D


@export_range(0, 10, 0.001, "or_greater")
var light : float = 1.0 :
	set(v):
		light = v
		if not self.is_inside_tree():
			await ready
		if get_parent() is Node2D:
			get_parent().self_modulate = Color(light,light,light)


func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is Node2D:
		return ["父节点不是 Node2D 类型的节点！"]
	return []
