class_name Fan extends Node2D

const Carpet = preload("res://src/component/carpet/carpet.gd")

static var BLOWABLE := [Carpet]

@export var speed: float = 200
@export var radius: int = 3
@export var direction: Vector2i = Vector2i.RIGHT
var player_inside: bool = false

func _process(_delta: float) -> void:
	var sprite: Sprite2D = $Sprite2D
	if Engine.get_process_frames() % 16 == 0:
		sprite.frame = (sprite.frame + 1) % (sprite.hframes * sprite.vframes)

func _physics_process(delta: float) -> void:
	var player: CharacterBody2D = GameCore.player
	var obj_layer: TileMapLayer = GameCore.now_action.obj_layer
	var fan_coords: Vector2i = obj_layer.local_to_map(global_position)
	var rect: Rect2i
	if direction == Vector2i.LEFT:
		rect = Rect2i(fan_coords.x - 1, fan_coords.y, -radius, 1).abs()
	if direction == Vector2i.RIGHT:
		rect = Rect2i(fan_coords.x + 1, fan_coords.y, radius, 1).abs()
	if direction == Vector2i.UP:
		rect = Rect2i(fan_coords.x, fan_coords.y - 1, 1, -radius).abs()
	if direction == Vector2i.DOWN:
		rect = Rect2i(fan_coords.x, fan_coords.y + 1, 1, radius).abs()
	if player != null:
		var player_coords: Vector2i = player._local_to_tilemap()
		var target_coords: Vector2i = player_coords + direction
		var target_position: Vector2 = obj_layer.map_to_local(target_coords)
		var room: Room = GameCore.now_action.room
		if rect.has_point(player_coords) && Rect2i(room.position, room.size).has_point(target_position):
			player.state = player.State.FLOATING
			player.move_toward_collide(direction, delta)
			player_inside = true
		elif player.state == player.State.FLOATING && player_inside:
			player.state = player.State.WALKING
			player.make_inside()
			player_inside = false
	if obj_layer != null:
		for obj in obj_layer.get_children():
			var obj_coords: Vector2i = obj_layer.local_to_map(obj.global_position)
			if obj.get_script() in BLOWABLE && rect.has_point(obj_coords):
				## 是可移动的物体
				# CARPET
				if obj.type != Carpet.CarpetType.EXPAND:
					obj.move(direction,true)
