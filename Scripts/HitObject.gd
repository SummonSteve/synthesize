extends Node

enum HitObjectType {
	NOTE,
	NOTE_SPLIT,
	PRESS_START,
	PRESS_END,
}

enum Track {
	NULL,
	TRACK1,
	TRACK2
}

class HitObject:
	var index: int
	var track: int
	var type: int
	var start_time: int
	var translation_x: int

