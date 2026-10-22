extends RefCounted
## One gesture, one intent. Delays tap until release to disambiguate hold/pinch.

signal action_requested(id: int)
signal inspection_requested(id: int)
signal pan_requested(delta: Vector2)
signal zoom_requested(factor: float, anchor: Vector2)

var picker: Callable
var mode: String = "idle"
var points: Dictionary = {}
var start := Vector2.ZERO
var previous := Vector2.ZERO
var start_plot: int = -1
var elapsed: float = 0
var visited: Dictionary = {}
var threshold: float = 12
var camera_tool: bool = false


func cancel() -> void:
	mode = "idle"
	points.clear()
	visited.clear()
	elapsed = 0


func press(position: Vector2, pointer: int = 0, force_pan: bool = false) -> void:
	points[pointer] = position
	if points.size()>1:
		mode = "pinch"
		return
	start = position
	previous = position
	start_plot = int(picker.call(position))
	visited.clear()
	elapsed = 0
	mode = "pan" if force_pan or camera_tool or start_plot<0 else "pending"


func _paint(point: Vector2) -> void:
	var id := int(picker.call(point))
	if id>=0 and not visited.has(id):
		visited[id] = true
		action_requested.emit(id)


func move(position: Vector2, pointer: int = 0) -> void:
	if not points.has(pointer):
		return
	var old: Vector2 = points[pointer]
	points[pointer] = position
	if mode=="pinch":
		if points.size()==2:
			var keys := points.keys()
			var other: Vector2 = points[keys[0] if keys[1]==pointer else keys[1]]
			var old_distance := old.distance_to(other)
			if old_distance>8:
				zoom_requested.emit(position.distance_to(other)/old_distance,(position+other)/2)
		return
	if mode=="pending" and start.distance_to(position)>threshold:
		mode = "paint"
		_paint(start)
	if mode=="paint":
		# Sample fast strokes so sparse mouse/touch events cannot skip a plot.
		var samples := mini(256,maxi(1,int(ceil(old.distance_to(position)/8.0))))
		for i in range(1,samples+1):
			_paint(old.lerp(position,float(i)/samples))
	elif mode=="pan":
		pan_requested.emit(position-old)
	previous = position


func release(position: Vector2, pointer: int = 0, canceled: bool = false) -> void:
	if not points.has(pointer):
		return
	if mode=="pending" and not canceled and int(picker.call(position))==start_plot:
		_paint(position)
	points.erase(pointer)
	if points.is_empty():
		cancel()
	elif mode=="pinch":
		# Remaining finger never becomes an action after a pinch.
		mode = "pinch"


func tick(delta: float) -> void:
	if mode=="pending":
		elapsed += delta
		if elapsed>=0.55:
			mode = "inspect"
			inspection_requested.emit(start_plot)
