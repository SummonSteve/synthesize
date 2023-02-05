extends AudioStreamPlayer

export var game_playing = false

func _on_MusicStreamPlayer_finished():
	if !game_playing:
		yield(get_tree().create_timer(1), "timeout")
		play()
