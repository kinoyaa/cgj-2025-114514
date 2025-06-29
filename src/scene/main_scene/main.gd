extends Control

## TODO 失败特效

@export var level_vp:SubViewport

@onready var cover_effect: ColorRect = %cover_effect

func _ready() -> void:
	resized.connect(
		func():
			set_param("screen_width",size.x)
			set_param("screen_height",size.y)
	)

func set_param(vname : String,value):
	cover_effect.material.set_shader_parameter(vname,value)
	pass

func _on_example_gameover() -> void:
	var level = level_vp.get_child(0)
	var vpPos = (level_vp.canvas_transform * level_vp.global_canvas_transform) * level.player.get_global_position()
	var scene:PackedScene = load(scene_file_path)
	assert(scene)
	gameover_transition.target_scene = scene.instantiate()
	gameover_transition.play(vpPos + level_vp.get_parent().position)
