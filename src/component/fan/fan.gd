@tool
class_name Fan extends Obj

const Carpet = preload("res://src/component/carpet/carpet.gd")

static var BLOWABLE := [Carpet]

@export var speed: float = 200
@export var radius: int = 3
@export var direction: Vector2i = Vector2i.RIGHT
var player_inside: bool = false

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
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

static func get_instance_by_direction(pull_direction : Vector2i) -> Fan:
	match pull_direction:
		Vector2i.DOWN:
			return load("res://src/component/fan/fan_down.tscn").instantiate()
		Vector2i.UP:
			return load("res://src/component/fan/fan_up.tscn").instantiate()
		Vector2i.RIGHT:
			return load("res://src/component/fan/fan_right.tscn").instantiate()
		Vector2i.LEFT:
			return load("res://src/component/fan/fan_left.tscn").instantiate()
	return null
