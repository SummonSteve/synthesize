extends Node2D

onready var animation_player = $AnimationPlayer
onready var parent = get_parent()

export var folder_name = ""
export var title = ""

signal selected_changed


func _ready():
	$TextureRect/Label.text = title

func _on_TextureRect_mouse_entered():
	animation_player.play("out")


func _on_TextureRect_mouse_exited():
	animation_player.play_backwards("out")


func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			parent.current_select = folder_name
