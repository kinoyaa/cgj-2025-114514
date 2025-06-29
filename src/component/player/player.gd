extends CharacterBody2D

static var UNPASSABLE := [Fan]

signal died

# 调试开关
@export var debug_draw: bool = false

# 配置参数
@export var speed: float = 200.0
@export var action: Node
@export var tilemap: TileMapLayer

# 信号
signal step_trigger
signal step_over

enum State {
	IDLE,
	WALKING,
	FLOATING,
}

var is_blown_by_fan: bool = false  # 是否被风扇吹动

var last_walk_direction: Vector2i = Vector2i.RIGHT  # 记录最后行走方向

@export var state: State = State.IDLE:
	set(new_state):
		if state == State.WALKING && new_state != State.WALKING:
			make_inside()
			step_trigger.emit()
		elif new_state == State.WALKING:
			last_walk_direction = current_direction  # 进入行走状态时记录方向
		state = new_state

@onready var pc_r: SpineSprite = %pc_r
@onready var pc_f: SpineSprite = %pc_f
@onready var pc_b: SpineSprite = %pc_b

# Animations
@onready var current_spine: SpineSprite = pc_r
var current_anim_name: String = ""
var current_direction: Vector2i = Vector2i.ZERO

var dead := false

func _ready() -> void:
	assert(tilemap, "请分配tilemap!")
	GameCore.player = self
	make_inside()
	set_process(debug_draw)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"walk"):
		if state != State.FLOATING:
			state = State.WALKING if state != State.WALKING else State.IDLE

func _physics_process(delta: float) -> void:
	if state == State.WALKING:
		_keep_walk(delta)
		# 右侧障碍物检测
		var cell_data = tilemap.get_cell_tile_data(_local_to_tilemap() + Vector2i.RIGHT)
		var target = _local_to_tilemap() + current_direction
		if cell_data and cell_data.get_custom_data("type") == "carpet":
			state = State.IDLE
			make_inside()
		for node : Node2D in action.obj_layer.get_children():
			if target == tilemap.local_to_map(node.global_position):
				# 障碍检测
				if node is Carpet:
					if node.type != Fan.Carpet.CarpetType.EXPAND:
						state = State.IDLE
						make_inside()
				if node is Fan:
					state = State.IDLE
					make_inside()
		# 不能超出背景没刷的地方
		if action.background_layer.get_cell_source_id(target) == -1:
			state = State.WALKING
			make_inside()
	elif state == State.FLOATING && !is_blown_by_fan:
		# 如果处于漂浮状态但没有被风扇吹动，则切换到空闲状态
		state = State.IDLE
		set_anim(Vector2i.ZERO, "Idle")
		velocity = Vector2.ZERO
	elif state == State.IDLE && current_anim_name != "Idle":
		# 只在需要时设置空闲动画
		set_anim(Vector2i.ZERO, "Idle")
		velocity = Vector2.ZERO
	queue_redraw()

func _keep_walk(delta):
	if state != State.WALKING:
		return
	move_toward_collide(Vector2i.RIGHT, delta)

func move_toward_collide(direction: Vector2i, delta: float) -> void:
	#if is_blown_by_fan:
		## 被风吹且有阻碍时，检查右侧是否可以放置
		#var forward_coords = _local_to_tilemap() + direction
		#if GameCore.now_action.carpet_can_puton(forward_coords):
			#velocity = Vector2i.RIGHT * speed * delta
			#set_anim(Vector2i.RIGHT, "Walk")
			#move_and_collide(velocity)
			#return
	
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
	
	current_direction = direction
	current_anim_name = anim_name
	_apply_direction_sprite(direction)
	switch_anim(current_spine, anim_name)

func _apply_direction_sprite(direction: Vector2i):
	# 先全部隐藏
	pc_r.visible = false
	pc_f.visible = false
	pc_b.visible = false
	
	match direction:
		Vector2i.RIGHT:
			current_spine = pc_r
			pc_r.scale.x = abs(pc_r.scale.x)
			pc_r.visible = true
		Vector2i.LEFT:
			current_spine = pc_r
			pc_r.scale.x = -abs(pc_r.scale.x)
			pc_r.visible = true
		Vector2i.UP:
			current_spine = pc_b
			pc_b.visible = true
		Vector2i.DOWN:
			current_spine = pc_f
			pc_f.visible = true
		_:  # 默认情况（如Vector2i.ZERO）
			current_spine = pc_r
			pc_r.visible = true

func switch_anim(spine_sprite: SpineSprite, anim_name: String):
	var animation_state = spine_sprite.get_animation_state()
	var current = animation_state.get_current(0)
	
	if not current or current.get_animation().get_name() != anim_name:
		animation_state.set_animation(anim_name)

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
	
	# 动画状态
	var anim_text = "动画: " + current_anim_name
	
	# 绘制文本
	draw_string(ThemeDB.fallback_font, pos, dir_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
	draw_string(ThemeDB.fallback_font, pos + Vector2(0, 40), anim_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)

func make_inside():
	var t = create_tween()
	t.tween_property(self, "position", tilemap.map_to_local(_local_to_tilemap()), 0.4)
	t.tween_callback(func(): step_over.emit())

func _local_to_tilemap() -> Vector2i:
	return tilemap.local_to_map(self.global_position)

func die():
	if dead:
		return
	
	dead = true
	died.emit()
