extends Control

## TODO 失败特效

@export var level_vp: SubViewport
@export var content_scene : CanvasModulate
@export var next_scene : PackedScene

@export var cursor_sound : AudioStream
@export var click_sound : AudioStream
@export var retryOrQuit_sound : AudioStream

@onready var cover_effect: ColorRect = %cover_effect
@onready var menu_layer: CanvasLayer = %menu_layer

func _ready() -> void:
	resized.connect(
		func():
			set_param("screen_width",size.x)
			set_param("screen_height",size.y)
	)
	content_scene.gameover.connect(
		func():
			retry()
	)
	content_scene.won.connect(
		func():
			if next_scene:
				var level = content_scene
				var vpPos = (level_vp.canvas_transform * level_vp.global_canvas_transform) * level.player.get_global_position()
				gameover_transition.target_scene = next_scene.instantiate()
				gameover_transition.play(vpPos + level_vp.get_parent().position)
			else:
				back_to_title()
	)
	for node in get_tree().get_nodes_in_group("btn"):
		node.mouse_entered.connect(
			func():
				node.get_child(0).show()
				if cursor_sound:
					sound_bus.play_sound(cursor_sound)
		)
		node.mouse_exited.connect(
			func():
				node.get_child(0).hide()
		)
		node.pressed.connect(
			func():
				match node.name:
					"menu":
						menu_layer.show()
						sound_bus.play_sound(retryOrQuit_sound)
					"continue":
						menu_layer.hide()
						sound_bus.play_sound(click_sound)
					"retry":
						retry()
						sound_bus.play_sound(retryOrQuit_sound)
					"quit":
						back_to_title()
						sound_bus.play_sound(retryOrQuit_sound)
		)

func back_to_title():
	var level = content_scene
	var vpPos = (level_vp.canvas_transform * level_vp.global_canvas_transform) * level.player.get_global_position()
	var scene:PackedScene = load("res://src/scene/title/title_scene.tscn")
	assert(scene)
	gameover_transition.target_scene = scene.instantiate()
	gameover_transition.play(vpPos + level_vp.get_parent().position)

func retry():
	var level = content_scene
	var vpPos = (level_vp.canvas_transform * level_vp.global_canvas_transform) * level.player.get_global_position()
	var scene:PackedScene = load(scene_file_path)
	assert(scene)
	gameover_transition.target_scene = scene.instantiate()
	gameover_transition.play(vpPos + level_vp.get_parent().position)

func set_param(vname : String,value):
	cover_effect.material.set_shader_parameter(vname,value)
	pass
