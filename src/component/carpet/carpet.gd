@tool
extends Obj
class_name Carpet

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
				sprite.frame = 6
			CarpetType.VERTICAL:
				sprite.frame = 7
			CarpetType.HORIZONTAL:
				sprite.frame = 8

var moving_tween: Tween = null
@onready var sprite: Sprite2D = %sprite

func _ready() -> void:
	super()
	

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
