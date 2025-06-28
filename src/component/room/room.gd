@tool
class_name Room extends StaticBody2D

@export var tilemap : TileMapLayer

@export var tile_size = 128

@export var size: Vector2i = Vector2i(1024, 1024):
	set(new_size):
		size = new_size
		queue_redraw()

func _ready() -> void:
	var bound_left := WorldBoundaryShape2D.new()
	var bound_right := WorldBoundaryShape2D.new()
	var bound_up := WorldBoundaryShape2D.new()
	var bound_down := WorldBoundaryShape2D.new()
	bound_left.normal = Vector2.RIGHT
	bound_right.normal = Vector2.LEFT
	bound_up.normal = Vector2.DOWN
	bound_down.normal = Vector2.UP
	var shape_owner_left := create_shape_owner(self)
	var shape_owner_right := create_shape_owner(self)
	var shape_owner_up := create_shape_owner(self)
	var shape_owner_down := create_shape_owner(self)
	shape_owner_add_shape(shape_owner_left, bound_left)
	shape_owner_add_shape(shape_owner_right, bound_right)
	shape_owner_add_shape(shape_owner_up, bound_up)
	shape_owner_add_shape(shape_owner_down, bound_down)
	shape_owner_set_transform(shape_owner_right, Transform2D(0, Vector2(size.x, 0)))
	shape_owner_set_transform(shape_owner_down, Transform2D(0, Vector2(0, size.y)))
	size = tilemap.get_used_rect().size * tile_size

func _draw() -> void:
	var rect := Rect2(Vector2(0, 0), size)
	var box := StyleBoxTexture.new()
	box.texture = preload("res://src/assets/imgs/shadow.png")
	box.texture_margin_left = 256
	box.texture_margin_right = 256
	box.texture_margin_top = 256
	box.texture_margin_bottom = 256
	box.draw(get_canvas_item(), rect)
	if !Engine.is_editor_hint():
		return
	draw_rect(rect, Color.AQUA, false)
