extends AudioStreamPlayer
class_name SoundPlayer

const GROUP = "Sound"

func _init():
	add_to_group(GROUP)

func _ready():
	volume_db = volume_setting.get_final_volume_db(GROUP)
