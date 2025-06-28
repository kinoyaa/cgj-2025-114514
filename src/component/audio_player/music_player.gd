extends AudioStreamPlayer
class_name MusicPlayer

const GROUP = "Music"

func _init():
	add_to_group(GROUP)

func get_final_volume():
	return  volume_setting.get_final_volume(GROUP)

func get_final_volume_db():
	return  volume_setting.get_final_volume_db(GROUP)

func _ready():
	volume_db = get_final_volume_db()
