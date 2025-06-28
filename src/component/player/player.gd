extends CharacterBody2D

static var UNPASSABLE := [Fan]

# 配置参数
@export var speed: float = 200.0
# 指定tilemap
@export var tilemap: TileMapLayer

# 落脚时触发的信号
signal step_trigger
signal step_over

enum State {
	IDLE,
	WALKING,
	FLOATING,
}

@export var state: State = State.IDLE:
	set(new_state):
		if state == State.WALKING && new_state != State.WALKING:
			make_inside()
			step_trigger.emit()
			print("inside")
		state = new_state
@onready var spine_sprite: SpineSprite = %SpineSprite


# 返回当前在哪个tilemap的单元格
func _local_to_tilemap() -> Vector2i:
	return tilemap.local_to_map(self.global_position)

# 始终向右走
func _keep_walk(delta):
	if state != State.WALKING:
		return
	move_toward_collide(Vector2i.RIGHT, delta)

func move_toward_collide(direction: Vector2i, delta: float) -> void:
	var target_coords = _local_to_tilemap() + direction
	var target_position = tilemap.map_to_local(target_coords)
	var room: Room = get_tree().current_scene.get_node_or_null("Room")
	if !Rect2i(room.position, room.size).has_point(target_position):
		make_inside()
		return
	var trap_layer: TileMapLayer = get_tree().current_scene.get_node_or_null("trapLayer")
	if trap_layer != null:
		for trap in trap_layer.get_children():
			var trap_coords: Vector2i = trap_layer.local_to_map(trap.global_position)
			if trap_coords == target_coords && trap.get_script() in UNPASSABLE:
				return
	velocity = direction * speed * delta
	move_and_collide(velocity)

# 使自身居中于该单元格
func make_inside():
	var t = create_tween()
	t.tween_property(
		self,"position",tilemap.map_to_local(_local_to_tilemap()),0.4
		)
	t.tween_callback(func(): step_over.emit())

#region overrides
func _ready() -> void:
	assert(tilemap,"请分配tilemap!")
	GameCore.player = self
	make_inside()
	spine_sprite.get_animation_state().set_animation("animation")

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"walk"):
		if state == State.WALKING:
			state = State.IDLE
		elif state == State.IDLE:
			state = State.WALKING

func _physics_process(delta: float) -> void:
	if state == State.WALKING:
		_keep_walk(delta)
	else:
		velocity = Vector2.ZERO

func _draw() -> void:
	pass

#endregion
