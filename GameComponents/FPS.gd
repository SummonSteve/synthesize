extends Label

var frame_rate: int = Engine.get_frames_per_second()
func _process(_delta: float) -> void:
	frame_rate = Engine.get_frames_per_second()
	set_text("fps:" + str(frame_rate) + "\n" + str(stepify(1000/float(frame_rate), 0.01)) + "ms")
