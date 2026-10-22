extends Node
## Empty, safe integration for mastered audio. Never synthesizes a final soundtrack.

var cues: Dictionary = {}
var loops: Array[AudioStreamPlayer] = []
var voices: Array[AudioStreamPlayer] = []
var cursor: int = 0
var cooldown: float = 0

func _ready() -> void:
	for bus in ["Music","Ambient","SFX","UI"]:
		if AudioServer.get_bus_index(bus)<0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count-1,bus)
	var slots: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/audio_slots.json"))
	for key in slots:
		if not slots[key] is Dictionary:
			continue
		var slot: Dictionary = slots[key]
		if slot.get("path","").is_empty() or slot.get("review_status","")!="APPROVED" or not slot.get("commercial_embedding",false):
			continue
		if not ResourceLoader.exists(slot.path):
			continue
		var stream: AudioStream = load(slot.path)
		if slot.get("loop",false):
			var player := AudioStreamPlayer.new()
			player.stream = stream
			player.bus = slot.bus
			player.volume_db = -18
			add_child(player)
			loops.append(player)
		else:
			cues[key] = {"stream":stream,"bus":slot.bus}
	for i in range(6):
		var player := AudioStreamPlayer.new()
		player.volume_db = -10
		add_child(player)
		voices.append(player)

func _process(delta: float) -> void:
	cooldown = maxf(0,cooldown-delta)

func play(key: String) -> void:
	if not cues.has(key) or cooldown>0:
		return
	var voice := voices[cursor]
	voice.stream = cues[key].stream
	voice.bus = cues[key].bus
	voice.play()
	cursor = (cursor+1)%voices.size()
	cooldown = 0.035

func set_ambience(enabled: bool) -> void:
	for player in loops:
		if enabled and not player.playing:
			player.play()
		elif not enabled:
			player.stop()

func _exit_tree() -> void:
	for player in voices+loops:
		player.stop()
