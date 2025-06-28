extends Node2D

var moving_tween: Tween = null

func move(direction: Vector2i) -> void:
	if moving_tween != null and moving_tween.is_running():
		return
	var layer := get_parent() as TileMapLayer
	var to_coords := layer.local_to_map(global_position) + direction
	if layer != null:
		for trap in layer.get_children():
			var trap_coords: Vector2i = layer.local_to_map(trap.global_position)
			if trap_coords == to_coords:
				return
	var to_position := layer.map_to_local(to_coords)
	var room: Room = get_tree().current_scene.get_node_or_null("Room")
	if !Rect2i(room.position, room.size).has_point(to_position):
		return
	moving_tween = create_tween()
	moving_tween.tween_property(self, "position", to_position, 1)
