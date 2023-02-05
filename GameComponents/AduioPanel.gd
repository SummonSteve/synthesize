extends Node2D

onready var animation_player = $AnimationPlayer

onready var music_player = $"../../MusicStreamPlayer"

onready var master_progress = $Sprite/Container/MasterProgress
onready var music_progress = $Sprite/Container/MusicProgress
onready var effects_progress = $Sprite/Container/EffectsProgress
onready var master_text = $Sprite/Container/Master
onready var music_text = $Sprite/Container/Music
onready var effects_text = $Sprite/Container/Effects

onready var timer = $Timer

enum select_section {
	MASTER,
	MUSIC,
	EFFECTS
}

var current_select = select_section.MASTER

var music_volume: int = 80
var effets_vloume: int = 100
var master_weight: int = 100
var panel_opened: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	music_player.volume_db = range_lerp(master_weight, 0, 100, -60, 10) - 80 * range_lerp(music_volume, 0, 100, 1, 0)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
			_panel_process()
			music_player.volume_db = range_lerp(master_weight, 0, 100, -60, 10) - 80 * range_lerp(music_volume, 0, 100, 1, 0)
	
func _on_panel_timeout():
	animation_player.play_backwards("panel_in")
	panel_opened = false


func _on_Timer_timeout():
	_on_panel_timeout()
	timer.stop()



func _panel_process():
	if Input.is_action_just_released("mouse_wheel_up"):
		if current_select == select_section.MASTER:
			if master_weight < 100 :
				master_weight += 5
				master_progress.value = master_weight
				master_text.text = "Master: " + str(master_weight)
		elif current_select == select_section.MUSIC:
			if music_volume < 100:
				music_volume += 5
				music_progress.value = music_volume
				music_text.text = "Music: " + str(music_volume)
		elif current_select == select_section.EFFECTS:
			if effets_vloume < 100:
				effets_vloume += 5
				effects_progress.value = effets_vloume
				effects_text.text = "Effects: " + str(effets_vloume)
	elif Input.is_action_just_released("mouse_wheel_down"):
		if current_select == select_section.MASTER:
			if master_weight > 0 :
				master_weight -= 5
				master_progress.value = master_weight
				master_text.text = "Master: " + str(master_weight)
		elif current_select == select_section.MUSIC:
			if music_volume > 0:
				music_volume -= 5
				music_progress.value = music_volume
				music_text.text = "Music: " + str(music_volume)
		elif current_select == select_section.EFFECTS:
			if effets_vloume > 0:
				effets_vloume -= 5
				effects_progress.value = effets_vloume
				effects_text.text = "Effects: " + str(effets_vloume)
	if not panel_opened:
		animation_player.play("panel_in")
		panel_opened = true
		timer.start()


func _on_EffectsProgress_mouse_entered():
	current_select = select_section.EFFECTS

func _on_MusicProgress_mouse_entered():
	current_select = select_section.MUSIC

func _on_MasterProgress_mouse_entered():
	current_select = select_section.MASTER
