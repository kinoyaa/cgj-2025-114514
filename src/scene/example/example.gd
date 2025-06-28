extends Node2D

@export var player: CharacterBody2D  # 引用player节点

@export var background_layer : TileMapLayer
@export var trap_layer : TileMapLayer
@export var obj_layer : TileMapLayer
@export var room : Room

@export var camera : Camera2D

# 第一次点击的地图坐标
var _clicked_coord : Vector2i
# 放下鼠标时的地图坐标（记录拖动）
var _released_coord : Vector2i
# 正触发的物品
var target_object

const SOURCE_ID = 0
const CARPET_EXPAND = Vector2i(0,1)
const CARPET_VERTICAL = Vector2i(1,1)
const CARPET_HORIZONTAL = Vector2i(2,1)

# 可被吹动的物品池
var fan_blow_able : Array = []

func _ready() -> void:
	if !player and !obj_layer:
		push_warning("未赋值！")
	GameCore.now_action = self
	_connect_signal()
	set_process(true)

func _connect_signal():
	# FAN 可被吹动
	for body in obj_layer.get_children():
		if body.get_script() in Fan.BLOWABLE:
			fan_blow_able.append(body)
	obj_layer.child_entered_tree.connect(
		func(body : Node):
			if body.get_script() in Fan.BLOWABLE:
				fan_blow_able.append(body)
	)

func _process(delta: float) -> void:
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			_clicked_coord = obj_layer.local_to_map(get_global_mouse_position())
			# 目标物体
			target_object = obj_layer.get_cell_tile_data(_clicked_coord)
			for node : Node2D in fan_blow_able:
				if _clicked_coord == obj_layer.local_to_map(node.global_position):
					target_object = node
		else:
			_released_coord = obj_layer.local_to_map(get_global_mouse_position())
			# 拉动方向
			var pull_direction = get_grid_direction(_clicked_coord,_released_coord)
			# 拉动结合方向的的目标位置
			var pull_target = _clicked_coord + pull_direction
			if target_object != null:
				# 节点形式的
				if target_object is Node and carpet_can_puton(pull_target):
					if target_object is Fan.Carpet:
						target_object.move(pull_direction,false)
						match target_object.type:
							Fan.Carpet.CarpetType.EXPAND:
								if verticalOrHorizontal(pull_direction):
									target_object.type = Fan.Carpet.CarpetType.VERTICAL
								else:
									target_object.type = Fan.Carpet.CarpetType.HORIZONTAL
							Fan.Carpet.CarpetType.VERTICAL:
								if verticalOrHorizontal(pull_direction):
									target_object.type = Fan.Carpet.CarpetType.EXPAND
								else:
									target_object.type = Fan.Carpet.CarpetType.VERTICAL
							Fan.Carpet.CarpetType.HORIZONTAL:
								if verticalOrHorizontal(pull_direction):
									target_object.type = Fan.Carpet.CarpetType.HORIZONTAL
								else:
									target_object.type = Fan.Carpet.CarpetType.EXPAND
						pass
				# 图块形式的
				elif target_object is TileData:
					if pull_direction != Vector2i.ZERO:
						if target_object.has_custom_data("type"):
							match target_object.get_custom_data("type"):
								#地毯
								"carpet":
									if carpet_can_puton(pull_target):
										# 删掉原位置的
										obj_layer.erase_cell(_clicked_coord)
										match target_object.get_custom_data("direction"):
											"vertical":
												if pull_direction == Vector2i.UP or pull_direction == Vector2i.DOWN:
													obj_layer.set_cell(pull_target,SOURCE_ID,CARPET_EXPAND)
												elif pull_direction == Vector2i.LEFT or pull_direction == Vector2i.RIGHT:
													obj_layer.set_cell(pull_target,SOURCE_ID,CARPET_VERTICAL)
											"horizontal":
												if pull_direction == Vector2i.UP or pull_direction == Vector2i.DOWN:
													obj_layer.set_cell(pull_target,SOURCE_ID,CARPET_HORIZONTAL)
												elif pull_direction == Vector2i.LEFT or pull_direction == Vector2i.RIGHT:
													obj_layer.set_cell(pull_target,SOURCE_ID,CARPET_EXPAND)
								"carpet_expand":
									if carpet_can_puton(pull_target):
										# 删掉原位置的
										obj_layer.erase_cell(_clicked_coord)
										if pull_direction == Vector2i.UP or pull_direction == Vector2i.DOWN:
											obj_layer.set_cell(pull_target,SOURCE_ID,CARPET_VERTICAL)
										elif pull_direction == Vector2i.LEFT or pull_direction == Vector2i.RIGHT:
											obj_layer.set_cell(pull_target,SOURCE_ID,CARPET_HORIZONTAL)

## 判断横向纵向
func verticalOrHorizontal(pull_direction) -> bool:
	if pull_direction == Vector2i.UP or pull_direction == Vector2i.DOWN:
		return true
	elif pull_direction == Vector2i.LEFT or pull_direction == Vector2i.RIGHT:
		return false
	return false

## TODO 检测地毯是否能放到指定地方
func carpet_can_puton(target : Vector2i) -> bool:
	var condition1 = obj_layer.get_cell_source_id(target) == -1
	var condition2 = player._local_to_tilemap() != target
	return condition1 and condition2

# 输入：当前坐标 (current_pos) 和目标坐标 (target_pos)
func get_grid_direction(current_pos: Vector2i, target_pos: Vector2i) -> Vector2i:
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
