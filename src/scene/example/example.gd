extends Node2D

@export var player: CharacterBody2D  # 引用player节点
@export var tilemap: TileMapLayer

# 第一次点击的地图坐标
var _clicked_coord : Vector2
# 放下鼠标时的地图坐标（记录拖动）
var _released_coord : Vector2
# 正触发的物品
var target_object

func _ready() -> void:
	if !player and !tilemap:
		push_warning("未赋值！")
	set_process(true)

func _process(delta: float) -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			_clicked_coord = tilemap.local_to_map(get_global_mouse_position())
			target_object = tilemap.get_cell_tile_data(_clicked_coord)
		else:
			_released_coord = tilemap.local_to_map(get_global_mouse_position())
			# 拉动方向
			var pull_direction = get_grid_direction(_clicked_coord,_released_coord)
			# 拉动结合方向的的目标位置
			var pull_target = _clicked_coord + pull_direction
			if pull_direction != Vector2.ZERO and target_object != null:
				if target_object.has_custom_data("type"):
					match target_object.get_custom_data("type"):
						#地毯
						"carpet":
							if carpet_can_puton(pull_target):
								# 删掉原位置的
								tilemap.erase_cell(_clicked_coord)
								match target_object.get_custom_data("direction"):
									"vertical":
										if pull_direction == Vector2.UP or pull_direction == Vector2.DOWN:
											tilemap.set_cell(pull_target,1,Vector2i(2,0))
										elif pull_direction == Vector2.LEFT or pull_direction == Vector2.RIGHT:
											tilemap.set_cell(pull_target,1,Vector2i(0,0))
									"horizontal":
										if pull_direction == Vector2.UP or pull_direction == Vector2.DOWN:
											tilemap.set_cell(pull_target,1,Vector2i(1,0))
										elif pull_direction == Vector2.LEFT or pull_direction == Vector2.RIGHT:
											tilemap.set_cell(pull_target,1,Vector2i(2,0))
						"carpet_expand":
							if carpet_can_puton(pull_target):
								# 删掉原位置的
								tilemap.erase_cell(_clicked_coord)
								if pull_direction == Vector2.UP or pull_direction == Vector2.DOWN:
									tilemap.set_cell(pull_target,1,Vector2(0,0))
								elif pull_direction == Vector2.LEFT or pull_direction == Vector2.RIGHT:
									tilemap.set_cell(pull_target,1,Vector2(1,0))



## TODO 检测地毯是否能放到指定地方
func carpet_can_puton(released_coord : Vector2i) -> bool:
	return tilemap.get_cell_tile_data(released_coord) == null

# 输入：当前坐标 (current_pos) 和目标坐标 (target_pos)
func get_grid_direction(current_pos: Vector2i, target_pos: Vector2i) -> Vector2:
	var delta = target_pos - current_pos
	# 确保是正交方向（非斜向）
	if delta.x != 0 and delta.y != 0:
		return Vector2.ZERO
	if delta.x > 0:
		return Vector2.RIGHT
	elif delta.x < 0:
		return Vector2.LEFT
	elif delta.y > 0:
		return Vector2.DOWN
	elif delta.y < 0:
		return Vector2.UP
	else:
		return Vector2.ZERO
