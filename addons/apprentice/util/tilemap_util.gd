#============================================================
#    Tilemap Util
#============================================================
# - datetime: 2023-02-14 19:48:46
#============================================================
class_name TileMapUtil



## 获取这层的所有瓦片数据
static func get_cells(tilemap: TileMap, layer: int) -> Dictionary:
	var data : Dictionary = {}
	FuncUtil.for_rect(tilemap.get_used_rect(), func(coordinate: Vector2i):
		var source_id = tilemap.get_cell_source_id(layer, coordinate)
		var atlas_coord = tilemap.get_cell_atlas_coords(layer, coordinate)
		if source_id != -1:
			data[coordinate] = {
				"source_id": source_id,
				"atlas_coord": atlas_coord,
			}
	)
	return data


## 获取 TileMap 可通行路口
static func find_passageway(tilemap: TileMap) -> Dictionary:
	var door_data : Dictionary = {
		Vector2i.UP: Array([], TYPE_VECTOR2I, "", null),
		Vector2i.DOWN: Array([], TYPE_VECTOR2I, "", null),
		Vector2i.LEFT: Array([], TYPE_VECTOR2I, "", null),
		Vector2i.RIGHT: Array([], TYPE_VECTOR2I, "", null),
	}
	
	var rect = tilemap.get_used_rect()
	
	var left_column = rect.position.x
	var right_column = rect.end.x - 1
	var top_row = rect.position.y
	var bottom_row = rect.end.y - 1
	
	var coordinate : Vector2i
	# 每列
	for x in range(left_column + 1, right_column):
		coordinate = Vector2i(x, top_row)
		if (tilemap.get_cell_source_id(0, coordinate) == -1
			and (
				tilemap.get_cell_source_id(0, coordinate + Vector2i.LEFT) > -1
				or tilemap.get_cell_source_id(0, coordinate + Vector2i.RIGHT) > -1
			)
		):
			door_data[Vector2i.UP].append(coordinate)
		coordinate = Vector2i(x, bottom_row)
		if (tilemap.get_cell_source_id(0, coordinate) == -1
			and (
				tilemap.get_cell_source_id(0, coordinate + Vector2i.LEFT) > -1
				or tilemap.get_cell_source_id(0, coordinate + Vector2i.RIGHT) > -1
			)
		):
			door_data[Vector2i.DOWN].append(coordinate)
	
	# 每行
	for y in range(top_row, bottom_row):
		coordinate = Vector2i(left_column, y)
		if (tilemap.get_cell_source_id(0, coordinate) == -1
			and (tilemap.get_cell_source_id(0, coordinate + Vector2i.UP) > -1
				or tilemap.get_cell_source_id(0, coordinate + Vector2i.DOWN) > -1
			)
		):
			door_data[Vector2i.LEFT].append(coordinate)
		
		coordinate = Vector2i(right_column, y)
		if (tilemap.get_cell_source_id(0, coordinate) == -1
			and (tilemap.get_cell_source_id(0, coordinate + Vector2i.UP) > -1
				or tilemap.get_cell_source_id(0, coordinate + Vector2i.DOWN) > -1
			)
		):
			door_data[Vector2i.RIGHT].append(coordinate)
	
	return door_data


##  单元格是连通的
##[br]
##[br][code]tilemap[/code]  TileMap 对象
##[br][code]from[/code]  开始的坐标
##[br][code]to[/code]  到达的坐标
##[br][code]layer[/code]  所在的层
static func cell_is_connected(tilemap: TileMap, from: Vector2i, to: Vector2i, layer: int = 0) -> bool:
#	if (from - to).abs() == Vector2i.ONE:
#		return true
	var start = Vector2(from)
	var end = Vector2(to)
	var direction = start.direction_to(end)
	for step in floor(start.distance_to(end) - 1.0):
		start += direction
		var id = tilemap.get_cell_source_id(layer, Vector2i(start.round()))
		if id != -1:
			return false
	return true


##  获取这组点列表可以互相连接的点，两个点之间没有其他瓦片
##[br]
##[br][code]tilemap[/code]  
##[br][code]points[/code]  
##[br][code]layer[/code]  
static func get_connected_cell(tilemap: TileMap, points: Array, layer: int = 0) -> Array[Dictionary]:
	var list : Array[Dictionary]= []
	for i in points.size() - 1:
		for j in range(i + 1, points.size()):
			if cell_is_connected(tilemap, points[i], points[j], layer):
				list.append({
					"from": points[i],
					"to": points[j],
					"length": (points[i] - points[j]).length()
				})
	
	for idx in range(list.size() - 1, -1, -1):
		var data := Dictionary(list[idx])
		if (data['from'] == data['to']):
			list.remove_at(idx)
	
	return list


## 获取两边没有瓦片的单元格
static func get_around_no_tile_cell(tilemap: TileMap, coordinate: Vector2i, layer: int = 0, max_height: int = 1, max_width: int = 1) -> Array[Vector2i]:
	var id = tilemap.get_cell_source_id(layer, coordinate)
	var no_tiles : Array[Vector2i] = []
	if id != -1:
		for width in max_width:
			var left : Vector2i = coordinate + Vector2i(-width, 0)
			var right : Vector2i = coordinate + Vector2i(width, 0)
			for i in (max_height + 1):
				left -= Vector2i(0, i)
				if tilemap.get_cell_source_id(layer, left) > -1:
					no_tiles.append(left)
				right -= Vector2i(0, i)
				if tilemap.get_cell_source_id(layer, right) > -1:
					no_tiles.append(right)
	return no_tiles



## 获取这个坐标点两边的立足点。会返回两个项的数组，第一个为左边的点，第二个为右边的点，若为 null，则代表没有
static func get_foothold_coordinate(tilemap: TileMap, coordinate: Vector2i, layer: int = 0) -> Array:
	var used_rect = tilemap.get_used_rect()
	var left : Vector2i
	var right : Vector2i
	var coords : Array = [null, null]
	
	# 左。中上不能有其他瓦片
	if (tilemap.get_cell_source_id(layer, coordinate + Vector2i(-1, -1)) == -1
		and tilemap.get_cell_source_id(layer, coordinate + Vector2i(-1, 0)) == -1
	):
		for i in (used_rect.end.y - coordinate.y):
			left = coordinate + Vector2i(-1, i)
			if tilemap.get_cell_source_id(layer, left) != -1:
				coords[0] = left
				break
		
	# 右。中上不能有其他瓦片
	if (tilemap.get_cell_source_id(layer, coordinate + Vector2i(1, -1)) == -1
		and tilemap.get_cell_source_id(layer, coordinate + Vector2i(1, 0)) == -1
	):
		for i in (used_rect.end.y - coordinate.y):
			right = coordinate + Vector2i(1, i)
			if tilemap.get_cell_source_id(layer, right) != -1:
				coords[1] = right
				break
	
	return coords


## 获取可接触到的单元格点
static func get_touchable_coordinates(tilemap: TileMap, coordinate: Vector2i, touchable_height: int, touchable_width: int, layer: int = 0) -> Array:
	var list : Array = [null, null]
	
	# 头顶不能有碰撞的单元格
	for i in range(1, touchable_height + 1):
		if tilemap.get_cell_source_id(layer, coordinate + Vector2i(0, -i)) != -1:
			return list
		
	# 从中心向两边扩散，那一边的某列有，那这边是这个单元格可接触
	var left : Vector2i
	var right : Vector2i
	for y in range(1, touchable_height + 1):
		for x in range(1, touchable_width + 1):
			if list[0] == null:
				left = coordinate + Vector2i(-x, -y)
				if (tilemap.get_cell_source_id(layer, left) > -1
					and tilemap.get_cell_source_id(layer, left + Vector2i.UP) == -1
				):
					list[0] = left
			
			if list[1] == null:
				right = coordinate + Vector2i(x, -y)
				if (tilemap.get_cell_source_id(layer, right) > -1
					and tilemap.get_cell_source_id(layer, right + Vector2i.UP) == -1
				):
					list[1] = right
			
			if list[0] != null and list[1] != null:
				break
		
		if list[0] != null and list[1] != null:
			break
	
	return list


## 瓦片替换为节点
static func replace_tile_as_node_by_scene(tilemap: TileMap, layer: int, coordinate: Vector2i, tile_size: Vector2i, scene: PackedScene) -> Node:
	tilemap.set_cell(layer, coordinate, -1, Vector2(0, 0))
	
	# 替换场景节点
	var node = scene.instantiate()
	node.z_index = -10
	tilemap.add_child(node)
	node.global_position = tilemap.global_position + Vector2(tile_size * coordinate) 
	return node


