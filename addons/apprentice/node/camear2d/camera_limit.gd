#============================================================
#	Camera Limit By Map
#============================================================
# @datetime: 2022-3-15 00:34:43
#============================================================
## 设置镜头的有限的范围
class_name CameraLimit
extends BaseCameraByTileMap


## 额外设置的范围
@export var margin : Rect2 = Rect2(0,0,0,0)


#============================================================
#  SetGet
#============================================================
func get_limit():
	return Rect2( Vector2(camera.limit_left, camera.limit_top), Vector2(camera.limit_right, camera.limit_bottom) )


#============================================================
#   自定义
#============================================================
#(override)
func _update_camera():
	var rect = Rect2(tilemap.get_used_rect())
	if tilemap.tile_set == null:
		return
	
	var tile_size = Vector2(tilemap.tile_set.tile_size)
	rect.position *= tile_size
	rect.size *= tile_size
	rect.position += tilemap.global_position
	
	camera.limit_left = rect.position.x + margin.position.x
	camera.limit_right = rect.end.x + margin.size.x
	camera.limit_top = rect.position.y + margin.position.y
	camera.limit_bottom = rect.end.y + margin.size.y

