extends CharacterBody2D

static var UNPASSABLE := [Fan]

# 调试开关
@export var debug_draw: bool = true

# 配置参数
@export var speed: float = 200.0
@export var tilemap: TileMapLayer

# 信号
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
		state = new_state

@onready var pc_r: SpineSprite = %pc_r
@onready var pc_f: SpineSprite = %pc_f
@onready var pc_b: SpineSprite = %pc_b

# 动画控制变量
var current_spine: SpineSprite = pc_r
var current_anim_name: String = ""
var current_direction: Vector2i = Vector2i.ZERO
var last_shown_sprite: SpineSprite = null  # 记录当前显示的sprite


func _ready() -> void:
	assert(tilemap, "请分配tilemap!")
	GameCore.player = self
	make_inside()
	set_process(debug_draw)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"walk"):
		state = State.WALKING if state != State.WALKING else State.IDLE

func _physics_process(delta: float) -> void:
	if state == State.WALKING:
		_keep_walk(delta)
		var cell_data = tilemap.get_cell_tile_data(_local_to_tilemap() + Vector2i.RIGHT)
		if cell_data and cell_data.get_custom_data("type") == "carpet":
			state = State.IDLE
			make_inside()
	else:
		set_anim(Vector2i.ZERO, "Idle")
		velocity = Vector2.ZERO

func _keep_walk(delta):
	if state != State.WALKING:
		return
	move_toward_collide(Vector2i.RIGHT, delta)

func move_toward_collide(direction: Vector2i, delta: float) -> void:
	var target_coords = _local_to_tilemap() + direction
	var target_position = tilemap.map_to_local(target_coords)
	var room: Room = GameCore.now_action.room
	
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
	set_anim(direction, "Walk")
	move_and_collide(velocity)

func set_anim(direction: Vector2i, anim_name: String):
	if direction == current_direction and anim_name == current_anim_name:
		return  # 避免重复设置相同的动画
	
	# 确保方向有效
	var valid_direction = direction
	if direction not in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		valid_direction = Vector2i.ZERO
	
	# 调试信息：打印方向和调用栈
	print("方向: ", valid_direction, " | 调用来源: ", 
		"物理过程" if state == State.WALKING else 
		"空闲状态" if state == State.IDLE else 
		"漂浮状态")
	
	current_direction = valid_direction
	current_anim_name = anim_name
	_apply_direction_sprite(valid_direction)
	call_deferred("switch_anim", current_spine, anim_name)

func _apply_direction_sprite(direction: Vector2i):
	var target_sprite: SpineSprite = pc_r
	var need_update = false
	
	# 确定目标sprite和是否需要更新
	match direction:
		Vector2i.RIGHT:
			target_sprite = pc_r
			pc_r.scale.x = abs(pc_r.scale.x)
			if last_shown_sprite != pc_r:
				need_update = true
		Vector2i.LEFT:
			target_sprite = pc_r
			pc_r.scale.x = -abs(pc_r.scale.x)
			if last_shown_sprite != pc_r:
				need_update = true
		Vector2i.UP:
			target_sprite = pc_b
			if last_shown_sprite != pc_b:
				need_update = true
		Vector2i.DOWN:
			target_sprite = pc_f
			if last_shown_sprite != pc_f:
				need_update = true
		_:  # 默认情况
			target_sprite = pc_r
			if last_shown_sprite != pc_r:
				need_update = true
	
	# 只有需要更新时才执行显隐操作
	if need_update:
		if last_shown_sprite:
			last_shown_sprite.call_deferred("hide")
		target_sprite.call_deferred("show")
		last_shown_sprite = target_sprite
	
	current_spine = target_sprite

func switch_anim(spine_sprite: SpineSprite, anim_name: String):
	var animation_state = spine_sprite.get_animation_state()
	var current = animation_state.get_current(0)
	
	if not current or current.get_animation().get_name() != anim_name:
		animation_state.set_animation(anim_name)
	
	if debug_draw:
		queue_redraw()

func _draw():
	if not debug_draw:
		return
	
	# 绘制调试信息
	var pos = Vector2(10, 10)
	var color = Color.WHITE
	
	# 当前方向
	var dir_text = "方向: "
	match current_direction:
		Vector2i.RIGHT: dir_text += "右"
		Vector2i.LEFT: dir_text += "左"
		Vector2i.UP: dir_text += "上"
		Vector2i.DOWN: dir_text += "下"
		_: dir_text += "无"
	
	# 当前显示的sprite
	var sprite_text = "显示: "
	if last_shown_sprite == pc_r:
		sprite_text += "pc_r"
	elif last_shown_sprite == pc_f:
		sprite_text += "pc_f"
	elif last_shown_sprite == pc_b:
		sprite_text += "pc_b"
	else:
		sprite_text += "无"
	
	# 动画状态
	var anim_text = "动画: " + current_anim_name
	
	# 绘制文本
	draw_string(ThemeDB.fallback_font, pos, dir_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
	draw_string(ThemeDB.fallback_font, pos + Vector2(0, 20), sprite_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
	draw_string(ThemeDB.fallback_font, pos + Vector2(0, 40), anim_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)

func make_inside():
	var t = create_tween()
	t.tween_property(self, "position", tilemap.map_to_local(_local_to_tilemap()), 0.4)
	t.tween_callback(func(): step_over.emit())

func _local_to_tilemap() -> Vector2i:
	return tilemap.local_to_map(self.global_position)
