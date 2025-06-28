extends Control

## TODO 失败特效

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
