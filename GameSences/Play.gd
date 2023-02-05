extends Node

onready var objects = $"../Beatmap/Objects"
onready var tracker1 = $"../Player1"
onready var tracker2 = $"../Player2"
onready var hitobjects: Array

onready var effets_player = $"../../EffectsStreamPlayer"

onready var key1_overlay = $Node2D/KeyOverlay1/Key1
onready var key2_overlay = $Node2D/KeyOverlay1/Key2
onready var key3_overlay = $Node2D/KeyOverlay2/Key3
onready var key4_overlay = $Node2D/KeyOverlay2/Key4

onready var combo_text = $Node2D/Combo/Label
onready var combo_animation_player = $Node2D/Combo/AnimationPlayer

var combo = 0
var track1_hit_count = 0
var track2_hit_count = 0

var key1_pressed = false
var key2_pressed = false
var key3_pressed = false
var key4_pressed = false

onready var track1_progress = $Node2D/ProgressBar/ProgressBar/Track1Progress
onready var track2_progress = $Node2D/ProgressBar/ProgressBar/Track2Progress

onready var score_board = $Node2D/ScoreBoard

var track1_hitobject: Array = []
var track2_hitobject: Array = []

var track1_total_length = 0
var track2_total_length = 0

var key1_last = false
var key2_last = false
var key3_last = false
var key4_last = false

var highest_combo = 0
var track1_miss = 0
var track2_miss = 0

var initialized = false

var track2_next_hitobject = null
var track1_next_hitobject = null

var track1_can_hit = false
var track2_can_hit = false

var track1_hit_success = false
var track2_hit_success = false

export var game_mode = 0

enum GameMode {
	NORMAL,
	AUTO,
	RELAX,
}

func _ready():
	pass

func _process(_delta):
	_update_key_overlay()
	_play_sound()
	_update_track_progress()
	
	score_board.track1_miss = track1_miss
	score_board.track2_miss = track2_miss
	score_board.track1_ok = track1_hit_count
	score_board.track2_ok = track2_hit_count
	score_board.highest_combo = highest_combo 
		
		
func _update_track_progress():
	var _track1_pregress = len(track1_hitobject) / float(track1_total_length)
	var _track2_pregress = len(track2_hitobject) / float(track2_total_length)
	track1_progress.value = range_lerp(_track1_pregress, 1, 0, 0, 100)
	track2_progress.value = range_lerp(_track2_pregress, 1, 0, 0, 100)
	

func _update_hitobject():
	track1_hit_success = false
	track2_hit_success = false
	if track1_can_hit and (key1_pressed or key2_pressed):
		track1_next_hitobject = track1_hitobject.pop_front()
		var id = track1_next_hitobject.id
		var obj_instance = objects.get_child(id)
		obj_instance.visible = false
		track1_hit_success = true
		track1_can_hit = false
		track1_hit_count += 1
		combo += 1
		if combo > highest_combo:
			highest_combo = combo
		combo_text.text = str(combo) + "x"
		combo_animation_player.play("combo_add")
		
	if track2_can_hit and (key3_pressed or key4_pressed):
		track2_next_hitobject = track2_hitobject.pop_front()
		var id = track2_next_hitobject.id
		var obj_instance = objects.get_child(id)
		obj_instance.visible = false
		track2_hit_success = true
		track2_can_hit = false
		track2_hit_count += 1
		combo += 1
		if combo > highest_combo:
			highest_combo = combo
		combo_text.text = str(combo) + "x"
		combo_animation_player.play("combo_add")
		
	
func play_keysound():
	effets_player.play()

func _input(event):
	if event is InputEventKey:
		match event.scancode:
			90: 
				if event.is_pressed():
					key1_pressed = true
				else:
					key1_pressed = false
			88:
				if event.is_pressed():
					key2_pressed = true
				else:
					key2_pressed = false
			44:
				if event.is_pressed():
					key3_pressed = true
				else:
					key3_pressed = false
			46:
				if event.is_pressed():
					key4_pressed = true
				else:
					key4_pressed = false
	
func _on_Beatmap_ready():
	hitobjects = objects.get_children()
	for obj in hitobjects:
		if obj.track == 0:
			track1_total_length += 1
			track1_hitobject.push_back(obj)
		elif obj.track == 1:
			track2_total_length += 1
			track2_hitobject.push_back(obj)
		else:
			pass
	initialized = true

func _on_Player1_area_entered(area):
	if area.name == "HitArea":
		if game_mode == GameMode.AUTO:
			track1_next_hitobject = track1_hitobject.pop_front()
			var id = track1_next_hitobject.id
			var obj_instance = objects.get_child(id)
			obj_instance.visible = false
			combo += 1
			if combo > highest_combo:
				highest_combo = combo
			track1_hit_count += 1
			combo_text.text = str(combo) + "x"
			combo_animation_player.play("combo_add")
			yield(get_tree().create_timer(0.07), "timeout")
			effets_player.play()
			return
		
		track1_can_hit = true
	
func _on_Player2_area_entered(area):
	if area.name == "HitArea":
		if game_mode == GameMode.AUTO:
			track2_next_hitobject = track2_hitobject.pop_front()
			var id = track2_next_hitobject.id
			var obj_instance = objects.get_child(id)
			obj_instance.visible = false
			combo += 1
			if combo > highest_combo:
				highest_combo = combo
			track2_hit_count += 1
			combo_text.text = str(combo) + "x"
			combo_animation_player.play("combo_add")
			yield(get_tree().create_timer(0.07), "timeout")
			effets_player.play()
			return
		track2_can_hit = true

func _on_Player1_area_exited(area):
	if game_mode == GameMode.AUTO:
		return
	if area.name == "HitArea":
		if area.get_parent().track != 0:
			return
		if !track1_hit_success:
			area.get_parent().visible = false
			track1_miss += 1
			combo = 0
			track1_next_hitobject = track1_hitobject.pop_front()
		track1_can_hit = false
		track1_hit_success = false
		
func _on_Player2_area_exited(area):
	if game_mode == GameMode.AUTO:
		return
	if area.name == "HitArea":
		if area.get_parent().track != 1:
			return
		if !track2_hit_success:
			area.get_parent().visible = false
			track1_miss += 1
			combo = 0
			track2_next_hitobject = track2_hitobject.pop_front()
		track2_can_hit = false
		track2_hit_success = false


func _update_key_overlay():
	if key1_pressed:
		key1_overlay.modulate = Color(0, 0, 0, 1)
	else:
		key1_overlay.modulate = Color(1, 1, 1, 1)
	if key2_pressed:
		key2_overlay.modulate = Color(0, 0, 0, 1)
	else:
		key2_overlay.modulate = Color(1, 1, 1, 1)
	if key3_pressed:
		key3_overlay.modulate = Color(0, 0, 0, 1)
	else:
		key3_overlay.modulate = Color(1, 1, 1, 1)
	if key4_pressed:
		key4_overlay.modulate = Color(0, 0, 0, 1)
	else:
		key4_overlay.modulate = Color(1, 1, 1, 1)

func _do_click():
	_update_hitobject()
	play_keysound()

func _play_sound():
	if key1_pressed != key1_last:
		if key1_pressed == true:
			_do_click()
		key1_last = key1_pressed
		
	if key2_pressed != key2_last:
		if key2_pressed == true:
			_do_click()
		key2_last = key2_pressed
		
	if key3_pressed != key3_last:
		if key3_pressed == true:
			_do_click()
		key3_last = key3_pressed
		
	if key4_pressed != key4_last:
		if key4_pressed == true:
			_do_click()
		key4_last = key4_pressed
