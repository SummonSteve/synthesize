extends Node2D
onready var tween_out = get_node("Tween")

var map_list = []

onready var bg_sprite = $BG
onready var ep_sprite = $InfoPanel/EP
onready var animation_palyer= $AnimationPlayer
onready var music_player = $"../MusicStreamPlayer"

onready var normal_button = $Normal
onready var relax_button = $Relax
onready var auto_button = $Auto

var selected_mode = 0

var play = preload("res://GameSences/Play.tscn")
var select_tab = preload("res://GameComponents/SelectTab.tscn")
const Beatmap = preload("res://Scripts/Beatmap.gd")

export var current_select = "res://GameData/Songs/15 Voices - Non-breath oblige"
export var prev_select = "res://GameData/Songs/15 Voices - Non-breath oblige"

var song_list = [
	"res://GameData/Songs/15 Voices - Non-breath oblige",
	"res://GameData/Songs/PastelPalettes - Happy Synthesizer",
	"res://GameData/Songs/Faylan - INFINITE SKY",
	"res://GameData/Songs/Hana - Sakura no Uta",
	"res://GameData/Songs/Kotoha - God-ish",
	#"res://GameData/Songs/Sayuri - test",
	"res://GameData/Songs/Aqours - Aozora Jumping Heart",
	#"res://GameData/Songs/Monster Siren Records - Boiling Blood"
	"res://GameData/Songs/Sayuri - Hana no Tou",
	#"res://GameData/Songs/Yanagi Mami - Hikari Hanate!"
]

func _ready():
	$VolumeBack/TotalSongsNum.text = "共计" + str(len(song_list)) + "首曲目"
	for i in len(song_list):
		var tab = select_tab.instance()
		tab.translate(Vector2(0, i * 82 + 10))
		tab.folder_name = song_list[i]
		tab.title = song_list[i].split("Songs/")[1]
		add_child(tab)
		music_player.volume_db = -80
		tween_out.interpolate_property(music_player, "volume_db", -80, -15, 1, 1, Tween.EASE_IN, 0)
		tween_out.start()
		update_select()


func _load_maps(dir_str):
	var bg_path = dir_str + "/bg.jpg"
	var ep_path = dir_str + "/ep.jpg"
	var bg_texture = load(bg_path)
	var ep_texture = load(ep_path)
	var bg_texture_size = bg_texture.get_size()
	var ep_texture_size = ep_texture.get_size()
	var ep_th = 200
	var ep_tw = 200
	var bg_th = 600
	var bg_tw = 1024
	var bg_scale = Vector2(bg_tw/bg_texture_size.x, bg_th/bg_texture_size.y)
	var ep_scale = Vector2(ep_tw/ep_texture_size.x, ep_th/ep_texture_size.y)
	ep_sprite.texture = ep_texture
	ep_sprite.scale = ep_scale
	bg_sprite.texture = bg_texture
	bg_sprite.scale = bg_scale
		
func _input(event):
	if selected_mode == 0:
		normal_button.modulate.a = 1
		relax_button.modulate.a = 0.2
		auto_button.modulate.a = 0.2
	elif selected_mode == 1:
		normal_button.modulate.a = 0.2
		relax_button.modulate.a = 0.2
		auto_button.modulate.a = 1
	elif selected_mode == 2:
		normal_button.modulate.a = 0.2
		relax_button.modulate.a = 1
		auto_button.modulate.a = 0.2
	if event is InputEventMouseButton:
		if current_select != prev_select:
			update_select()

func _on_Start_mouse_entered():
	animation_palyer.play("StartButtonHover")

func update_select():
	var f = File.new()
	f.open(current_select + "/map_data.syn", File.READ)
	var preview_time = f.get_line().split("=")[1]
	var title = f.get_line().split("=")[1]
	var title_unicode = f.get_line().split("=")[1]
	var artist = f.get_line().split("=")[1]
	var artist_unicode = f.get_line().split("=")[1]
	var bpm = f.get_line().split("=")[1]
	f.close()
	$TitleUnicode.text = artist_unicode + " - " + title_unicode
	$Title.text = artist + " - " + title
	$BPM.text = "BPM: " + bpm
	music_player.stream = load(current_select + "/audio.mp3")
	music_player.play()
	music_player.seek(float(preview_time)/1000)
	_load_maps(current_select)
	
	prev_select = current_select
func _on_Start_mouse_exited():
	animation_palyer.play_backwards("StartButtonHover")

func _on_Auto_pressed():
	selected_mode = 1

func _on_Relax_pressed():
	selected_mode = 2

func _on_Normal_pressed():
	selected_mode = 0

func _on_Start_pressed():
	var instance = play.instance()
	instance.get_child(6).selected = current_select.split("Songs/")[1]
	instance.get_child(5).game_mode = selected_mode
	music_player.game_playing = true
	music_player.stop()
	music_player.stream = null
	get_parent().add_child(instance)
