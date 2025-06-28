extends CharacterBody2D

# 配置参数
@export var speed: float = 200.0
# 指定tilemap
@export var tilemap: TileMapLayer

# 落脚时触发的信号
signal step_trigger

enum State {
	IDLE,
	WALKING,
	FLOATING,
}

var state: State = State.IDLE:
	set(new_state):
		if state == State.WALKING && new_state != State.WALKING:
			make_inside()
			step_trigger.emit()
			print("inside")
		state = new_state

#var walking : bool = false:
#	set(v):
#		walking = v
#		if !walking:
#			make_inside()
#			step_trigger.emit()

# 返回当前在哪个tilemap的单元格
func _local_to_tilemap() -> Vector2i:
	return tilemap.local_to_map(self.global_position)

# 始终向右走
func _keep_walk(delta):
	if state != State.WALKING:
		return
	var direction = Vector2.RIGHT
	velocity = direction * speed * delta

# 使自身居中于该单元格
func make_inside():
	var t = create_tween()
	t.tween_property(
		self,"position",tilemap.map_to_local(_local_to_tilemap()),0.15
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

#region overrides
func _ready() -> void:
	if !tilemap:
		assert(true,"请分配tilemap!")
	make_inside()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"walk"):
		if state == State.WALKING:
			state = State.IDLE
		else:
			state = State.WALKING

func _physics_process(delta: float) -> void:
	if state == State.WALKING:
		_keep_walk(delta)
	else:
		velocity = Vector2.ZERO
	move_and_collide(velocity)
	pass

func _draw() -> void:
	pass

#endregion
