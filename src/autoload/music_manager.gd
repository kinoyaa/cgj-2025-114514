extends Node

var music_dir:String = "res://asset/audio/music/"

var base_bgm:AudioStream : set = set_base_bgm

var fade_out_time:float = 1
var fade_in_time:float = 1
var fade_out_ease := Tween.EASE_IN
var fade_in_ease := Tween.EASE_OUT

var current_player:MusicPlayer = null
var current_tween:Tween = null
var last_player:MusicPlayer = null
var last_tween:Tween = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_bgm(p_bgm:AudioStream):
	if last_player:
		if is_instance_valid(last_tween):
			last_tween.stop()
			last_tween.kill()
			last_tween = null
		
		last_player.queue_free()
		last_player = null
	
	
	if current_player:
		if is_instance_valid(current_tween):
			current_tween.stop()
			current_tween.kill()
			current_tween = null
		
		if fade_out_time > 0:
			last_player = current_player
			last_tween = create_tween()
			last_tween.tween_method(tween_player_volume_ratio.bind(last_player), 1.0, 0.0, fade_out_time).set_ease(fade_out_ease)
		else:
			current_player.queue_free()
	
	current_player = MusicPlayer.new()
	current_player.stream = p_bgm
	if fade_in_time > 0:
		current_tween = create_tween()
		current_tween.tween_method(tween_player_volume_ratio.bind(current_player), 0.0, 1.0, fade_in_time).set_ease(fade_in_ease)
	
	add_child(current_player)
	current_player.call_deferred("play")

func reset_bgm():
	set_bgm(base_bgm)

func tween_player_volume_ratio(p_value:float, p_player):
	if !is_instance_valid(p_player):
		return
	
	p_player.volume_db = linear_to_db(p_value * p_player.get_final_volume())

func set_base_bgm(p_bgm:AudioStream):
	if base_bgm == p_bgm:
		return
	
	var curBgm:bool = current_player == null || current_player.stream == base_bgm
	
	base_bgm = p_bgm
	
	if curBgm:
		reset_bgm()
