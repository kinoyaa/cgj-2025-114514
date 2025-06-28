@tool
class_name MouseAvoidText
extends Control

## 显示设置
@export_multiline var text: String = "":
	set(v):
		text = v
		_update_text()
		
@export var font: Font:
	set(v):
		font = v
		_update_text()

@export_range(1, 1000) var font_size: int = 16:
	set(v):
		font_size = v
		_update_text()

@export var font_color: Color = Color.WHITE:
	set(v):
		font_color = v
		queue_redraw()

## 对齐方式
@export_enum("Left", "Center", "Right") var alignment: int = 0:
	set(v):
		alignment = v
		_update_text()

@export_enum("Top", "Center", "Bottom") var vertical_alignment: int = 0:
	set(v):
		vertical_alignment = v
		_update_text()

## 避让设置
@export var avoid_radius: float = 100.0
@export var max_offset: float = 30.0
@export var smooth_speed: float = 5.0

# 私有变量
var _char_positions: Array[Vector2] = []
var _char_offsets: PackedVector2Array = []
var _char_indices: Array[int] = []  # 记录有效字符的原始索引
var _line_widths: Array[float] = []  # 记录每行宽度
var _label: Label

func _ready():
	_label = Label.new()
	_label.hide()
	add_child(_label)
	_update_text()
	resized.connect(_update_text)

func _process(delta):
	if Engine.is_editor_hint():
		return
	
	var mouse_pos = get_global_mouse_position()
	var changed = false
	
	for i in range(_char_offsets.size()):
		var char_global_pos = global_position + _char_positions[i]
		var to_mouse = char_global_pos - mouse_pos
		var distance = to_mouse.length()
		
		var target_offset = Vector2.ZERO
		if distance < avoid_radius:
			var dir = to_mouse.normalized()
			var strength = 1.0 - (distance / avoid_radius)
			target_offset = dir * max_offset * strength
		
		_char_offsets[i] = _char_offsets[i].lerp(target_offset, smooth_speed * delta)
		changed = true
	
	if changed:
		queue_redraw()

func _update_text():
	if not is_inside_tree() or not font:
		return
	
	_label.text = text
	_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", font_size)
	_label.size = Vector2.ZERO
	_label.reset_size()
	
	_char_positions.clear()
	_char_offsets = PackedVector2Array()
	_char_indices.clear()
	_line_widths.clear()
	
	# 计算文本总高度
	var line_count = max(1, text.count("\n") + 1)
	var text_height = line_count * font.get_height(font_size)
	
	# 计算垂直偏移
	var vertical_offset = 0.0
	match vertical_alignment:
		1: # Center
			vertical_offset = (size.y - text_height) / 2
		2: # Bottom
			vertical_offset = size.y - text_height
	
	# 设置基础位置，考虑字体基线
	var base_pos = Vector2(0, vertical_offset + font.get_ascent(font_size))
	var advance = Vector2.ZERO
	var current_line_width = 0.0
	var line_start_index = 0
	var line_char_count = 0
	
	# 第一次遍历：计算每行宽度和字符数量
	for i in range(text.length()):
		var char_str = text[i]
		
		if char_str == "\n":
			_line_widths.append(current_line_width)
			current_line_width = 0.0
			line_start_index = i + 1
			line_char_count = 0
			continue
		
		var char_width = font.get_string_size(char_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		current_line_width += char_width
		line_char_count += 1
	
	# 添加最后一行宽度
	if text.length() > 0:
		_line_widths.append(current_line_width)
	
	# 第二次遍历：计算字符位置
	var line_index = 0
	current_line_width = 0.0
	line_char_count = 0
	var line_start_x = 0.0
	
	for i in range(text.length()):
		var char_str = text[i]
		
		if char_str == "\n":
			# 应用对齐偏移到当前行的所有字符
			_apply_alignment_to_line(line_index, line_start_x, line_char_count)
			
			advance.x = 0
			advance.y += font.get_height(font_size)
			line_index += 1
			line_char_count = 0
			current_line_width = 0.0
			line_start_x = advance.x
			continue
		
		var char_width = font.get_string_size(char_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		
		# 记录字符位置（暂时不考虑对齐）
		_char_positions.append(base_pos + advance)
		_char_offsets.append(Vector2.ZERO)
		_char_indices.append(i)
		
		advance.x += char_width
		current_line_width += char_width
		line_char_count += 1
	
	# 应用对齐到最后一行
	if line_char_count > 0:
		_apply_alignment_to_line(line_index, line_start_x, line_char_count)
	
	queue_redraw()

func _apply_alignment_to_line(line_index: int, line_start_x: float, char_count: int):
	if line_index >= _line_widths.size() or char_count == 0:
		return
	
	var line_width = _line_widths[line_index]
	var total_width = size.x
	var offset_x = 0.0
	
	match alignment:
		1: # Center
			offset_x = (total_width - line_width) / 2.0 - line_start_x
		2: # Right
			offset_x = total_width - line_width - line_start_x
	
	if offset_x != 0.0:
		var start_index = _char_positions.size() - char_count
		for i in range(start_index, start_index + char_count):
			_char_positions[i].x += offset_x

func _draw():
	if not font or _char_positions.is_empty():
		return
	
	for i in range(_char_positions.size()):
		var original_index = _char_indices[i]
		if original_index >= text.length():
			continue
			
		var char_str = text[original_index]
		var pos = _char_positions[i] + _char_offsets[i]
		
		draw_string(
			font,
			pos,
			char_str,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			font_color
		)
