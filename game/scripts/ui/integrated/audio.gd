extends Node
## Licensed Kenney CC0 candidates, small bounded pool; no synthesized final audio.
var gain: float = 0.55
var muted: bool = false
var players: Array[AudioStreamPlayer] = []
var cues: Dictionary = {}
var last: Dictionary = {}
func _ready() -> void:
	var definitions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/integrated/audio.json"))
	for cue in definitions.cues:
		cues[cue] = load("res://assets/audio/integrated/"+definitions.cues[cue]+".ogg")
	for i in range(8):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX" if AudioServer.get_bus_index("SFX")>=0 else "Master"
		add_child(player); players.append(player)
func set_ambience(_enabled: bool) -> void: pass # No unlicensed ambience/music is substituted.
func play(action: String) -> void:
	if muted or gain<=0 or not cues.has(action): return
	var now: int = Time.get_ticks_msec()
	if now-int(last.get(action,-1000))<55: return
	last[action] = now
	for player in players:
		if not player.playing:
			player.stream = cues[action]
			player.volume_db = linear_to_db(gain)-19
			player.pitch_scale = 1
			player.play()
			return

func _exit_tree() -> void:
	for player in players:
		player.stop()
		player.stream = null
	cues.clear()
