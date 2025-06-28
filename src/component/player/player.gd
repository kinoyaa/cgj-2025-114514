extends CharacterBody2D

# 配置参数
@export var speed: float = 15000.0
# 指定tilemap
@export var tilemap: TileMapLayer

var walking : bool = false:
	set(v):
		walking = v
		if !walking:
			make_inside()
			pass

# 返回当前在哪个tilemap的单元格
func _local_to_tilemap() -> Vector2i:
	return tilemap.local_to_map(self.global_position)

# 始终向右走
func _keep_walk(delta):
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
		if walking:
			walking = false
		else:
			walking = true

func _physics_process(delta: float) -> void:
	if walking:
		_keep_walk(delta)
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	pass

func _draw() -> void:
	
	pass

#endregion
