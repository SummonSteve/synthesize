extends Spatial


export(float) var max_separation = 20.0
export(float) var split_line_thickness = 3.0
export(Color, RGBA) var split_line_color = Color.black
export(bool) var adaptive_split_line_thickness = true

onready var player1 = $"../Player1"
onready var player2 = $"../Player2"
onready var view = $View
onready var viewport1 = $Viewport1
onready var viewport2 = $Viewport2
onready var camera1 = viewport1.get_node(@"Camera1")
onready var camera2 = viewport2.get_node(@"Camera2")


func _ready():
	_on_size_changed()
	_update_splitscreen()

	get_viewport().connect("size_changed", self, "_on_size_changed")

	view.material.set_shader_param("viewport1", viewport1.get_texture())
	view.material.set_shader_param("viewport2", viewport2.get_texture())


func _process(_delta):
	_move_cameras()
	_update_splitscreen()


func _move_cameras():
	var position_difference = _compute_position_difference_in_world()

	var distance = clamp(_compute_horizontal_length(position_difference), 0, max_separation)

	position_difference = position_difference.normalized() * distance

	camera1.translation.x = player1.translation.x + position_difference.x / 2.0
	camera1.translation.z = player1.translation.z + position_difference.z / 2.0

	camera2.translation.x = player2.translation.x - position_difference.x / 2.0
	camera2.translation.z = player2.translation.z - position_difference.z / 2.0


func _update_splitscreen():
	var screen_size = get_viewport().get_visible_rect().size
	var player1_position = camera1.unproject_position(player1.translation) / screen_size
	var player2_position = camera2.unproject_position(player2.translation) / screen_size

	var thickness
	if adaptive_split_line_thickness:
		var position_difference = _compute_position_difference_in_world()
		var distance = _compute_horizontal_length(position_difference)
		thickness = lerp(0, split_line_thickness, (distance - max_separation) / max_separation)
		thickness = clamp(thickness, 0, split_line_thickness)
	else:
		thickness = split_line_thickness

	view.material.set_shader_param("split_active", _get_split_state())
	view.material.set_shader_param("player1_position", player1_position)
	view.material.set_shader_param("player2_position", player2_position)
	view.material.set_shader_param("split_line_thickness", thickness)
	view.material.set_shader_param("split_line_color", split_line_color)


func _get_split_state():
	var position_difference = _compute_position_difference_in_world()
	var separation_distance = _compute_horizontal_length(position_difference)
	return separation_distance > max_separation


func _on_size_changed():
	var screen_size = get_viewport().get_visible_rect().size

	$Viewport1.size = screen_size
	$Viewport2.size = screen_size

	view.material.set_shader_param("viewport_size", screen_size)


func _compute_position_difference_in_world():
	return player2.translation - player1.translation


func _compute_horizontal_length(vec):
	return Vector2(vec.x, vec.z).length()
