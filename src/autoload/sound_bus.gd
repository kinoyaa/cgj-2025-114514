extends Node

var unuse_sound_player_list := []

func play_sound(p_sound:AudioStream):
	if p_sound == null:
		return
	
	var player
	if unuse_sound_player_list.is_empty():
		player = SoundPlayer.new()
		add_child(player)
		player.finished.connect(_on_sound_player_finished.bind(player))
	else:
		player = unuse_sound_player_list.pop_back()
	
	player.stream = p_sound
	player.play()

func _on_sound_player_finished(p_player):
	unuse_sound_player_list.append(p_player)
