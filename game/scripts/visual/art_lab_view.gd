extends Node2D
## Diagnostic lab. Legacy sprites are NOT normalized/final production assets.

const ENV = preload("res://assets/art/g05/environment_atlas_v1.png")
const CROPS = preload("res://assets/art/g05/crops_atlas_v1.png")
const ANIMALS = preload("res://assets/art/g05/animals_atlas_v1.png")
var model: RefCounted
var plots: Array[Dictionary] = []
var palette: bool = false
var guides: bool = true
var selected: int = -1
var elapsed: float = 0
var motion: bool = true

func _process(delta: float) -> void:
	if motion:
		elapsed += delta
		queue_redraw()

func frame_at(durations: Array, phase: float) -> int:
	var length: float = 0
	for duration in durations:
		length += float(duration)
	var local := fmod(phase,length)
	for i in range(durations.size()):
		local -= float(durations[i])
		if local<0:
			return i
	return 0

func sprite(texture: Texture2D, region: Rect2, anchor: Vector2, canvas: Vector2, pivot: Vector2) -> void:
	# One declared legacy adapter, never a per-frame size/zoom compensation.
	var factor := minf(canvas.x/region.size.x,canvas.y/region.size.y)
	var size := region.size*factor
	draw_texture_rect_region(texture,Rect2(anchor-pivot,size),region,Color("ecd9bc") if palette else Color.WHITE)

func _draw() -> void:
	if model==null:
		return
	var font := ThemeDB.fallback_font
	var ordered := plots.duplicate()
	ordered.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.cell.x+a.cell.y<b.cell.x+b.cell.y)
	for plot in ordered:
		var at: Vector2 = model.project(plot.cell)
		var cell := 0
		match plot.state:
			"planted": cell = 1
			"growing": cell = 2
			"mature": cell = 3
		var tint := Color(0.55,0.58,0.55) if plot.state=="locked" else Color.WHITE
		if palette:
			tint *= Color("edc999")
		draw_texture_rect_region(CROPS,Rect2(at-Vector2(32,48),Vector2(64,57)),Rect2(cell*384,0,384,341),tint)
		if guides:
			var diamond := PackedVector2Array([at+Vector2(0,-16),at+Vector2(32,0),at+Vector2(0,16),at+Vector2(-32,0),at+Vector2(0,-16)])
			draw_polyline(diamond,Color("edd787"),1)
		if plot.state=="locked":
			draw_string(font,at+Vector2(-3,-7),"B",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color.WHITE)
		elif plot.state=="empty":
			draw_string(font,at+Vector2(-3,-7),"V",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("f5e6bd"))
	for item in [
		[Rect2(15,50,540,535),Vector2(-5,-4),Vector2(144,143),Vector2(72,130)],
		[Rect2(560,80,440,510),Vector2(-6,1),Vector2(70,81),Vector2(35,75)],
		[Rect2(1010,285,516,310),Vector2(1,-5),Vector2(64,38),Vector2(32,34)]
	]:
		sprite(ENV,item[0],model.project(item[1]),item[2],item[3])
	var timing: Dictionary = model.standard.legacy_preview_timing
	var chicken_frame := frame_at(timing.chicken_idle,elapsed)
	var dog_frame := frame_at(timing.dog_attention,elapsed+0.9)
	sprite(ANIMALS,Rect2([130,488,846,1195][chicken_frame],20,220,236),model.project(Vector2(-1,-3)),Vector2(14,15),Vector2(7,14))
	sprite(ANIMALS,Rect2([100,455,815,1175][dog_frame],512,255,266),model.project(Vector2(-3,-3)),Vector2(22,23),Vector2(11,21))
	# A ruler is intentionally a debug aid, not an invented final character sprite.
	var ruler: Vector2 = model.project(Vector2(-1,-6))
	draw_line(ruler,ruler-Vector2(0,32),Color("fff2b1"),1)
	draw_line(ruler-Vector2(3,0),ruler+Vector2(3,0),Color("fff2b1"),1)
	draw_line(ruler-Vector2(3,32),ruler+Vector2(3,-32),Color("fff2b1"),1)
	draw_string(font,ruler+Vector2(6,-20),"32 px",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color.WHITE)
	if selected>=0 and selected<plots.size():
		var at: Vector2 = model.project(plots[selected].cell)
		draw_rect(Rect2(at-Vector2(34,50),Vector2(68,68)),Color("f7d46b"),false,1)
