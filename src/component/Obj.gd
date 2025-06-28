extends Node2D
class_name Obj

var layer : TileMapLayer
signal step_over

func _ready() -> void:
	layer = get_parent() as TileMapLayer
	make_inside()
	pass

# 使自身居中于该单元格
func make_inside():
	var t = create_tween()
	t.tween_property(
		self,"position",layer.map_to_local(_local_to_tilemap()),0.4
		)
	t.tween_callback(func(): step_over.emit())

# 返回当前在哪个tilemap的单元格
func _local_to_tilemap() -> Vector2i:
	return layer.local_to_map(self.global_position)
