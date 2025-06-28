extends Node

const SOUND_GROUP = "Sound"
const MUSIC_GROUP = "Music"
const GROUP_LIST = [ SOUND_GROUP, MUSIC_GROUP ]
const TOTAL_KEY = "Total"
const ENABLE_SUFFIX_KEY = "_enable"
const DEFAULT_VOLUME = 0.5

class GroupData:
	var name:String
	var enabled:bool = true
	var volume:float
	
	func _init(p_name:String, p_enabled:bool, p_volume:float):
		name = p_name
		enabled = p_enabled
		volume = p_volume

var total_volume:float = 1
var group_data_list := []

func _enter_tree():
	if !Engine.is_editor_hint():
		for i in GROUP_LIST:
			var default = DEFAULT_VOLUME
			if i == MUSIC_GROUP:
				default = 0.3
			group_data_list.append(GroupData.new(i, user_setting.get_value(i + ENABLE_SUFFIX_KEY, true), user_setting.get_value(i, default)))
	
		total_volume = user_setting.get_value(TOTAL_KEY, 1.0)


func set_total_volume(p_volume):
	total_volume = p_volume
	user_setting.set_value(TOTAL_KEY, total_volume)
	for i in group_data_list:
		update_volume(i.name)

func get_total_volume() -> float:
	return total_volume

func update_volume(p_group:String):
	var nodes = get_tree().get_nodes_in_group(p_group)
	var db = get_final_volume_db(p_group)
	for i in nodes:
		i.set_volume_db(db)

func set_group_volume(p_group:String, p_volume):
	for i in group_data_list:
		if i.name != p_group:
			continue
		
		i.volume = p_volume
	
	user_setting.set_value(p_group, p_volume)
	update_volume(p_group)

func get_group_volume(p_group:String) -> float:
	for i in group_data_list:
		if i.name != p_group:
			continue
		
		return i.volume
	
	return DEFAULT_VOLUME

func get_final_volume_db(p_group:String) -> float:
	var gVol
	if !is_group_enabled(p_group):
		gVol = 0
	else:
		gVol = get_group_volume(p_group)
	return linear_to_db(gVol * get_total_volume())

func get_final_volume(p_group:String) -> float:
	var gVol
	if !is_group_enabled(p_group):
		gVol = 0
	else:
		gVol = get_group_volume(p_group)
	return gVol * get_total_volume()

func enable_group(p_group:String):
	for i in group_data_list:
		if i.name != p_group:
			continue
		
		if i.enabled:
			return
		
		i.enabled = true
		user_setting.set_value(p_group + ENABLE_SUFFIX_KEY, i.enabled)
		update_volume(p_group)

func disable_group(p_group:String):
	for i in group_data_list:
		if i.name != p_group:
			continue
		
		if !i.enabled:
			return
		
		i.enabled = false
		user_setting.set_value(p_group + ENABLE_SUFFIX_KEY, i.enabled)
		update_volume(p_group)

func is_group_enabled(p_group:String) -> bool:
	for i in group_data_list:
		if i.name != p_group:
			continue
		
		return i.enabled
	
	return true
