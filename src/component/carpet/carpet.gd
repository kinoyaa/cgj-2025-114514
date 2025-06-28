extends Node2D

@export var duration_speed := 0.4

enum CarpetType{
	EXPAND,
	VERTICAL,
	HORIZONTAL
}
@export var type : CarpetType:
	set(v):
		type = v
		await get_tree().create_timer(duration_speed/2).timeout
		match type:
			CarpetType.EXPAND:
				sprite.frame = 5
			CarpetType.VERTICAL:
				sprite.frame = 6
			CarpetType.HORIZONTAL:
				sprite.frame = 7

var moving_tween: Tween = null
@onready var layer : TileMapLayer = get_parent() as TileMapLayer
@onready var sprite: Sprite2D = %sprite

signal step_over

func _ready() -> void:
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

func move(target: Vector2i,fan : bool) -> void:
	if moving_tween != null and moving_tween.is_running():
		return
	var to_coords := layer.local_to_map(global_position) + target
	if layer != null:
		for obj in layer.get_children():
			var obj_coords: Vector2i = layer.local_to_map(obj.global_position)
			if obj_coords == to_coords:
				return
	var to_position := layer.map_to_local(to_coords)
	var room: Room = GameCore.now_action.room
	if !Rect2i(room.position, room.size).has_point(to_position):
		return
	moving_tween = create_tween()
	moving_tween.tween_property(self, "position", to_position, duration_speed)
	if fan:
		type = CarpetType.EXPAND
