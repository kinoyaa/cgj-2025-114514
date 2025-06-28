extends Node

const SECTION = "-"

var config := ConfigFile.new()
var save_path := ""

func get_save_path() -> String:
	if save_path == "":
		save_path = _get_save_path()
	
	return save_path

func _get_save_path() -> String:
	if OS.get_name() == "Windows":
		return OS.get_executable_path().get_base_dir() + "/config.cfg"
	
	return "user://config.cfg"

func _enter_tree():
	load_settings()


func _notification(p_what):
	if p_what == NOTIFICATION_WM_WINDOW_FOCUS_OUT || p_what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()

func save_settings():
	var path = get_save_path()
# warning-ignore:return_value_discarded
	config.save(path)

func load_settings():
	var path = get_save_path()
	if FileAccess.file_exists(path):
# warning-ignore:return_value_discarded
		config.load(path)

func set_value(p_key, p_value):
	config.set_value(SECTION, p_key, p_value)

func get_value(p_key, p_default = null):
	return config.get_value(SECTION, p_key, p_default)

func has_key(p_key):
	return config.has_section_key(SECTION, p_key)
