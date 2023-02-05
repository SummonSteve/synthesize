extends Node2D

onready var animation_player = $AnimationPlayer
onready var objects = $"../../../Beatmap"
onready var root =  $"../../../../World"
onready var music_player = $"../../../../MusicStreamPlayer"

export var highest_combo = 0
export var track1_ok = 0
export var track2_ok = 0
export var track1_miss = 0
export var track2_miss = 0

onready var track1_miss_capsule = $MissCapsule1
onready var track2_miss_capsule = $MissCapsule2
onready var track1_ok_capsule = $OkCapsule1
onready var track2_ok_capsule = $OkCapsule2
onready var highest_combo_capsule = $ComboCapsule

func _ready():
	track1_miss_capsule.visible = false
	track2_miss_capsule.visible = false
	track1_ok_capsule.visible = false
	track2_ok_capsule.visible = false
	highest_combo_capsule.visible = false

func _on_TextureButton_mouse_entered():
	animation_player.play("exit_button_hover")


func _on_TextureButton_mouse_exited():
	animation_player.play_backwards("exit_button_hover")
	

func _on_TextureButton_pressed():
	objects.queue_free()
	animation_player.play_backwards("back_to_menu")
	yield(get_tree().create_timer(0.4), "timeout")
	music_player.game_playing = false
	music_player.volume_db = -15
	root.queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "spared":
		track1_miss_capsule.visible = true
		track2_miss_capsule.visible = true
		track1_ok_capsule.visible = true
		track2_ok_capsule.visible = true
		highest_combo_capsule.visible = true
		
		track1_miss_capsule.get_child(0).text = "Track1 Missed: " + str(track1_miss)
		track2_miss_capsule.get_child(0).text = "Track2 Missed: " + str(track2_miss)
		track1_ok_capsule.get_child(0).text = "Track1 Collected: " + str(track1_ok)
		track2_ok_capsule.get_child(0).text = "Track2 Collected: " + str(track2_ok)
		highest_combo_capsule.get_child(0).text = "Highest Combo: " + str(highest_combo)
