extends Node
## Original synthesized tones. Replace streams at this boundary after audio review.

var music_enabled: bool = false
var sfx_enabled: bool = true
var music: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var streams: Dictionary = {}
var next_voice: int = 0
var cooldown: float = 0


func _exit_tree() -> void:
	if is_instance_valid(music):
		music.stop()
	for voice in voices:
		voice.stop()


func _ready() -> void:
	for bus_name in ["Music", "SFX", "UI"]:
		if AudioServer.get_bus_index(bus_name)<0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count-1,bus_name)
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	music.volume_db = -21
	music.stream = _music_loop()
	add_child(music)
	for i in range(6):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		player.volume_db = -16
		add_child(player)
		voices.append(player)
	for key in ["plant","harvest","water","button"]:
		streams[key] = _tone(key)


func _process(delta: float) -> void:
	cooldown = maxf(0,cooldown-delta)


func set_music(enabled: bool) -> void:
	music_enabled = enabled
	if enabled:
		music.play()
	else:
		music.stop()


func play_cue(key: String) -> void:
	if not sfx_enabled or cooldown>0 or not streams.has(key):
		return
	var voice := voices[next_voice]
	voice.bus = "UI" if key=="button" else "SFX"
	voice.stream = streams[key]
	voice.play()
	next_voice = (next_voice+1)%voices.size()
	cooldown = 0.035


func _pcm(samples: PackedByteArray, loop: bool = false) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.data = samples
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = samples.size()/2
	return stream


func _tone(key: String) -> AudioStreamWAV:
	var duration: float = {"plant":0.14,"water":0.24,"harvest":0.28,"button":0.07}[key]
	var samples := PackedByteArray()
	samples.resize(int(duration*22050)*2)
	for i in range(samples.size()/2):
		var t := float(i)/22050.0
		var f: float = {"plant":420.0,"water":740.0,"harvest":660.0,"button":520.0}[key]
		if key=="harvest":
			f *= 1.0+floor(t/0.09)*0.25
		var wave := sin(TAU*f*t)*0.65+sin(TAU*(f*1.5)*t)*0.15
		if key=="water":
			wave = sin(TAU*(900-1200*t)*t)*sin(t*190)*0.6
		var envelope := minf(1,t/0.008)*pow(1-t/duration,2)
		samples.encode_s16(i*2,int(wave*envelope*12000))
	return _pcm(samples)


func _music_loop() -> AudioStreamWAV:
	# A quiet original eight-second pentatonic sketch, not a commercial music asset.
	var samples := PackedByteArray()
	samples.resize(8*22050*2)
	var notes := [261.63,329.63,392.0,440.0,392.0,329.63,293.66,261.63]
	for i in range(samples.size()/2):
		var t := float(i)/22050.0
		var local := fmod(t,1.0)
		var frequency: float = notes[int(t)]
		var envelope := sin(PI*local)*exp(-local*1.8)
		var wave := sin(TAU*frequency*t)*0.55+sin(TAU*frequency*0.5*t)*0.25
		samples.encode_s16(i*2,int(wave*envelope*7000))
	return _pcm(samples,true)
