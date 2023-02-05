extends Node

const HitObject = preload("res://Scripts/HitObject.gd")
const Note = preload("res://GameObject/Note.tscn")
const NoteSplit = preload("res://GameObject/NoteSplit.tscn")
const TrackSlice = preload("res://GameObject/TrackSlice.tscn")

var flow_speed = 20
var offset_distance = 5
var loacl_offset = 0
var ended = false
export var selected = ""

var track1_ended = false
var track2_ended = false

class Map:
	var preview_time: int
	var music_path: String
	var title: String
	var title_unicode: String
	var artist: String
	var artist_unicode: String
	var length: int
	var bpm: int
	var offset: int
	var hitobjects: Array

onready var objects_node = $Objects
onready var track_meshes = $TrackMesh

onready var music_player = get_parent().get_parent().get_node("MusicStreamPlayer")
onready var score_board_animation_player = $"../Play/Node2D/ScoreBoard/AnimationPlayer"

onready var offset_timer = $"../Timer"
onready var tracker1 = $"../Player1"
onready var tracker2 = $"../Player2"

var tracker1_x_velo = 0
var tracker2_x_velo = 0

var need_separate = false
var reach_start = false
var music_started = false

var map: Map = null

var track1_last_node: HitObject.HitObject = null
var track1_next_node: HitObject.HitObject = null
var track2_last_node: HitObject.HitObject = null
var track2_next_node: HitObject.HitObject = null

var track1_hitobjects: Array = []
var track2_hitobjects: Array = []


func _ready():
	map = load_beatmap(selected)
	print(float(offset_distance) / flow_speed + loacl_offset)
	offset_timer.wait_time = float(offset_distance) / flow_speed + loacl_offset
	offset_timer.one_shot = true
	offset_timer.start()
	var file = File.new()
	music_player.stream = load(map.music_path)
	_load_map(map)
	_create_track(map, 0)
	_create_track(map, 1)
	
	track1_last_node = track1_hitobjects.pop_front()
	track2_last_node = track2_hitobjects.pop_front()
	track1_next_node = track1_hitobjects.pop_front()
	track2_next_node = track2_hitobjects.pop_front()
	

func _process(delta):
	if ended:
		return
	if not music_started and reach_start:
		music_player.play()
		music_started = true
	if track1_ended and track2_ended:
		ended = true
		yield(get_tree().create_timer(0.5), "timeout")
		score_board_animation_player.play("spared")
		music_player.volume_db -= 10
	_update_tracker(delta)
	


func load_beatmap(floder_name) -> Map:
	var _map = Map.new()
	var f = File.new()
	var path = "res://GameData/Songs/" + floder_name + "/map_data.syn"
	_map.music_path =  "res://GameData/Songs/" + floder_name + "/audio.mp3"
	f.open(path, File.READ)
	_map.preview_time = f.get_line().split("=")[1]
	_map.title = f.get_line().split("=")[1]
	_map.title_unicode = f.get_line().split("=")[1]
	_map.artist = f.get_line().split("=")[1]
	_map.artist_unicode = f.get_line().split("=")[1]
	_map.bpm = f.get_line().split("=")[1]
	_map.offset = f.get_line().split("=")[1]
	_map.hitobjects = _load_hitobjects(f)
	f.close()
	return _map

func _load_hitobjects(f: File) -> Array:
	var index = 0
	var hitobjects = []
	while not f.eof_reached():
		var line = f.get_line()
		var hb_type = line.split(",")[0]
		var start_time = line.split(",")[1]
		var translation_x = line.split(",")[2]
		var track = line.split(",")[3]
		var hb = HitObject.HitObject.new()
		hb.start_time = start_time
		hb.type = hb_type
		hb.index = index
		hb.translation_x = translation_x
		hb.track = track
		hitobjects.push_back(hb)
		index += 1
	return hitobjects

func _load_map(map):
	for obj in map.hitobjects:
		if obj.track == 0:
			track1_hitobjects.push_back(obj)
		elif obj.track == 1:
			track2_hitobjects.push_back(obj)
		else:
			pass
		
		if obj.type == HitObject.HitObjectType.NOTE:
			var note = Note.instance()
			note.id = obj.index
			note.translation.z = offset_distance + flow_speed * obj.start_time / 1000.0
			note.translation.x = obj.translation_x
			var track_coll = note.get_child(0)
			var hit_coll = note.get_child(3)
			if obj.track == 0:
				note.track = 0
				track_coll.collision_layer = 1
				track_coll.collision_mask = 1
				hit_coll.collision_layer = 1
				hit_coll.collision_mask = 1
				var material = SpatialMaterial.new()
				material.albedo_color = Color(255 ,0, 0, 1)
				note.get_child(1).material_override = material
			elif obj.track == 1:
				note.track = 1
				track_coll.collision_layer = 2
				track_coll.collision_mask = 2
				hit_coll.collision_layer = 2
				hit_coll.collision_mask = 2
			objects_node.add_child(note)
		elif obj.type == HitObject.HitObjectType.NOTE_SPLIT:
			var note = NoteSplit.instance()
			note.translation.z = offset_distance + flow_speed * obj.start_time / 1000.0
			note.translation.x = obj.translation_x
			objects_node.add_child(note)
		elif obj.type == HitObject.HitObjectType.PRESS_START:
			pass
		elif obj.type == HitObject.HitObjectType.PRESS_END:
			pass


func _create_track(map, track_num):
	var hitobjects = []
	if track_num == 0:
		hitobjects = track1_hitobjects
	elif track_num == 1:
		hitobjects = track2_hitobjects
	for i in len(hitobjects) - 1:
		var obj = hitobjects[i]
		if obj.type == HitObject.HitObjectType.NOTE_SPLIT:
			_instance_meshes(hitobjects, obj, i, true)
		_instance_meshes(hitobjects, obj, i, false)
			
func _instance_meshes(hitobjects, obj, i, is_split):
	var track_slice = TrackSlice.instance()
	var mesh_instance = track_slice.get_child(0)
	var array_mesh = ArrayMesh.new()
	var material = SpatialMaterial.new()
	material.albedo_color = Color(0, 0, 0, 255)
	mesh_instance.translation.y = 1.2
	mesh_instance.material_override = material
	var next_obj
	if is_split:
		next_obj = track2_hitobjects[obj.index]
	else:
		next_obj = hitobjects[i + 1]
	var this_z = offset_distance + flow_speed * obj.start_time / 1000.0
	var this_x = obj.translation_x
	var next_z = offset_distance + flow_speed * next_obj.start_time / 1000.0
	var next_x = next_obj.translation_x
	var mesh_data  = _create_mesh_with_points(this_x, this_z, next_x, next_z)
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	mesh_instance.mesh = array_mesh
	track_meshes.add_child(track_slice)

func _create_mesh_with_points(this_x, this_z, next_x, next_z) -> Array:
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	mesh_data[ArrayMesh.ARRAY_VERTEX] = PoolVector3Array(
		[
			Vector3(this_x - 0.2, this_z, 0),
			Vector3(this_x + 0.2, this_z, 0),
			Vector3(next_x - 0.2, next_z, 0),
			Vector3(next_x + 0.2, next_z, 0),
		]
	)

	mesh_data[ArrayMesh.ARRAY_INDEX] = PoolIntArray(
		[
			0,1,2,
			3,2,1
		]
	)

	mesh_data[ArrayMesh.ARRAY_NORMAL] = PoolVector3Array(
		[
			Vector3(0, 0, -1),
			Vector3(0, 0, -1),
			Vector3(0, 0, -1),
			Vector3(0, 0, -1),
		]
	)
	return mesh_data

func _on_Timer_timeout():
	reach_start = true


func _on_Player1_area_entered(area):
	if area.name != "TrackPointArea":
		return
	if area.get_parent().name  == "SplitNode":
		need_separate = true
		tracker2.visible = true
	
	var x_to_move = track1_next_node.translation_x - track1_last_node.translation_x
	var move_time = float(track1_next_node.start_time - track1_last_node.start_time) / 1000
	if move_time == 0:
		track1_ended = true
		need_separate = false
		return
	tracker1_x_velo = x_to_move / move_time
	track1_last_node = track1_next_node
	if len(track1_hitobjects) != 0:
		track1_next_node = track1_hitobjects.pop_front()
		
		
	
func _on_Player2_area_entered(area):
	if area.name != "TrackPointArea":
		return
	if !need_separate:
		return
	var x_to_move = track2_next_node.translation_x - track2_last_node.translation_x
	var move_time = float(track2_next_node.start_time - track2_last_node.start_time) / 1000
	if move_time == 0:
		track2_ended = true
		need_separate = false
		return
	tracker2_x_velo = x_to_move / move_time
	track2_last_node = track2_next_node
	if len(track2_hitobjects) != 0:
		track2_next_node = track2_hitobjects.pop_front()
	
	
func _update_tracker(delta):
	if not need_separate:
		tracker2.visible = false
		tracker2.translation = tracker1.translation
	else:
		tracker2.translation.z += flow_speed * delta
		tracker2.translation.x += delta * tracker2_x_velo

	tracker1.translation.z += flow_speed * delta
	tracker1.translation.x += delta * tracker1_x_velo



