extends "res://scripts/audio/review_audio.gd"
## Adds review-gated care slots; absent masters remain silent, no synthesis.

func _ready() -> void:
	super._ready()
	var slots: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/g12/audio_slots.json"))
	for key in slots:
		var item: Dictionary = slots[key]
		if item.path.is_empty() or item.review_status!="APPROVED" or not item.commercial_embedding or not ResourceLoader.exists(item.path):
			continue
		cues[key] = {"stream":load(item.path),"bus":item.bus}
