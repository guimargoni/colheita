extends "res://scripts/ui/care/care_audio.gd"
## No synthesized substitute or unapproved master. Empty slots remain silent.
func _ready() -> void:
	super._ready()
	var slots: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/g13/audio_slots.json"))
	for key in slots:
		var item: Dictionary = slots[key]
		if item.path.is_empty() or item.review_status!="APPROVED" or not item.commercial_embedding or not ResourceLoader.exists(item.path):
			continue
		cues[key] = {"stream":load(item.path),"bus":item.bus}
