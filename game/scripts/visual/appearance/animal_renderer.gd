extends RefCounted
var clips: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/visual/v2/animation_clips.json"))
func draw(host: Node2D,kind: String,at: Vector2,id: String) -> void:
	if not host.animations.frames.has(kind):
		host.paint_asset("producer."+kind,"environment."+kind,at); return
	var remaining: float = float(host.animal_reactions.get(id,0))
	var action: String = str(host.animal_actions.get(id,"idle")) if remaining>0 else "idle"
	var clip: Dictionary = clips.animals[kind].get(action,clips.animals[kind].idle)
	if clip.has("fallback"): clip = clips.animals[kind][clip.fallback]
	var position: int = preload("res://scripts/visual/appearance/animation_clock.gd").frame(clip.durations,host.clock,id) if host.motion and host.intensity>0 else 0
	var frame: int = int(clip.frames[position])
	host.paint_asset("animal."+id,"animal."+kind+".frame."+str(frame),at)
