extends Node2D
## Original procedural block-art study. No third-party textures or gameplay state.

const FIXTURE_PATH := "res://data/visual/comparison_fixture.json"
const OUTLINE := Color("344936")
const GRASS := Color("87ab64")
const LIGHT := Color("bed58a")
const SOIL := Color("906044")
const CREAM := Color("ffedc4")
const WOOD := Color("ac7449")
const LEAF := Color("4c8051")
const PALE := Color("d9e5af")

var isometric: bool = true
var animation_enabled: bool = true
var clock: float = 0.0
var fixture: Dictionary = {}
var selected_plot: int = -1


func _ready() -> void:
	fixture = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE_PATH))
	queue_redraw()


func _process(delta: float) -> void:
	if animation_enabled:
		clock += delta
		queue_redraw()


func project(point: Vector2, height: float = 0.0) -> Vector2:
	if isometric:
		return Vector2((point.x - point.y) * 57.0, (point.x + point.y) * 28.5 - height)
	return Vector2(point.x * 74.0 + point.y * 7.0, point.y * 55.0 - height)


func unproject(point: Vector2) -> Vector2:
	if isometric:
		return Vector2((point.x / 57.0 + point.y / 28.5) / 2.0, (point.y / 28.5 - point.x / 57.0) / 2.0)
	var ground_y := point.y / 55.0
	return Vector2((point.x - ground_y * 7.0) / 74.0, ground_y)


func ground_rect(origin: Vector2, extent: Vector2, height: float = 0.0) -> PackedVector2Array:
	return PackedVector2Array([project(origin, height), project(origin + Vector2(extent.x, 0), height), project(origin + extent, height), project(origin + Vector2(0, extent.y), height)])


func poly(points: PackedVector2Array, color: Color, edge: bool = false) -> void:
	draw_colored_polygon(points, color)
	if edge:
		var closed := points.duplicate()
		closed.append(points[0])
		draw_polyline(closed, OUTLINE, 2.0, false)


func patch(origin: Vector2, extent: Vector2, color: Color, height: float = 0.0, edge: bool = false) -> void:
	poly(ground_rect(origin, extent, height), color, edge)


func box(origin: Vector2, extent: Vector2, height: float, color: Color, base: float = 0.0) -> void:
	var bottom := ground_rect(origin, extent, base)
	var top := ground_rect(origin, extent, base + height)
	poly(PackedVector2Array([bottom[1], bottom[2], top[2], top[1]]), color.darkened(0.24))
	poly(PackedVector2Array([bottom[2], bottom[3], top[3], top[2]]), color.darkened(0.10))
	poly(top, color)


func line3(a: Vector2, b: Vector2, height: float, color: Color, width: float = 3.0) -> void:
	draw_line(project(a, height), project(b, height), color, width, false)


func shadow(at: Vector2, radius: float) -> void:
	draw_set_transform(project(at) + Vector2(8, 5), 0, Vector2(1, 0.38))
	draw_circle(Vector2.ZERO, radius, Color(0.12, 0.24, 0.14, 0.19))
	draw_set_transform(Vector2.ZERO)


func plot_at(point: Vector2) -> int:
	var start := Vector2(fixture.get("plot_origin", [2.7, 3.0])[0], fixture.get("plot_origin", [2.7, 3.0])[1])
	var step: float = fixture.get("plot_spacing", 1.06)
	var tile: float = fixture.get("plot_size", 0.88)
	for row in range(4):
		for col in range(4):
			if Rect2(start + Vector2(col, row) * step, Vector2.ONE * tile).has_point(point):
				return row * 4 + col
	return -1


func _draw() -> void:
	if fixture.is_empty():
		return
	_draw_ground()
	_draw_paths()
	_draw_expansion()
	_fence(Vector2(-1.1,-1.0),Vector2(10.6,-1.0),20)
	_fence(Vector2(-1.1,-1.0),Vector2(-1.1,8.7),16)
	var objects: Array = fixture["objects"].duplicate(true)
	for row in range(4):
		for col in range(4):
			objects.append({"kind": "plot", "position": [2.7 + col * 1.06, 3.0 + row * 1.06], "id": row * 4 + col})
	objects.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return project(Vector2(a.position[0], a.position[1])).y < project(Vector2(b.position[0], b.position[1])).y)
	for object: Dictionary in objects:
		var at := Vector2(object.position[0], object.position[1])
		match object.kind:
			"plot": _draw_plot(at, int(object.id))
			"house": _draw_house(at)
			"tree": _draw_tree(at)
			"doghouse": _draw_doghouse(at)
			"dog": _draw_animal(at, "dog")
			"cow": _draw_animal(at, "cow")
			"chicken": _draw_animal(at, "chicken")
			"coop": _draw_coop(at)
			"hive": _draw_hive(at)
			"flowers": _draw_flowers(at)
			"barrel": box(at, Vector2(0.35, 0.4), 26, WOOD)
	_draw_fences()
	_draw_air()


func _draw_ground() -> void:
	# The board has one consistent projection; no warped source sprites.
	box(Vector2(-1.6, -1.6), Vector2(13.0, 11.8), 17, Color("5c7b48"), -21)
	patch(Vector2(-1.6, -1.6), Vector2(13.0, 11.8), GRASS, -2)
	for i in range(440):
		var x := -1.45 + fmod(float(i) * 0.773, 12.7)
		var y := -1.45 + fmod(float(i) * 1.413, 11.5)
		var p := Vector2(x, y)
		if Rect2(2.4, 2.6, 4.9, 4.8).has_point(p):
			continue
		var tint := Color("9cbb73") if i % 3 else Color("76985c")
		patch(p, Vector2(0.065, 0.035), tint)
		if i % 9 == 0:
			var s := project(p)
			draw_line(s, s + Vector2(0, -5), tint.darkened(0.12), 2)
			if i % 27 == 0:
				draw_rect(Rect2(s + Vector2(-2, -7), Vector2(4, 3)), CREAM)


func _draw_paths() -> void:
	patch(Vector2(1.1, 2.25), Vector2(6.6, 0.46), Color("d2be8a"))
	patch(Vector2(1.7, 2.2), Vector2(0.45, 6.8), Color("d2be8a"))
	patch(Vector2(2.2, 7.6), Vector2(5.1, 0.45), Color("d2be8a"))
	for i in range(16):
		patch(Vector2(1.5 + float(i) * 0.37, 2.32), Vector2(0.24, 0.28), Color("e8d7a8"))


func _draw_expansion() -> void:
	patch(Vector2(8.0, 0.1), Vector2(2.6, 8.4), Color("9eb77c"))
	for i in range(19):
		patch(Vector2(8.1, 0.2 + i * 0.43), Vector2(0.025, 0.21), PALE)
		patch(Vector2(10.4, 0.2 + i * 0.43), Vector2(0.025, 0.21), PALE)
	for i in range(5):
		patch(Vector2(8.2 + i * 0.47, 0.1), Vector2(0.22, 0.03), PALE)
		patch(Vector2(8.2 + i * 0.47, 8.35), Vector2(0.22, 0.03), PALE)
	var sign := project(Vector2(9.2, 5.4))
	draw_line(sign, sign + Vector2(0, -36), WOOD.darkened(0.2), 5)
	draw_style_box(_sign_style(), Rect2(sign + Vector2(-40, -60), Vector2(80, 30)))
	draw_string(ThemeDB.fallback_font, sign + Vector2(-31, -39), "EXPANDIR", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CREAM)


func _sign_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("526f46")
	style.set_corner_radius_all(4)
	return style


func _draw_plot(at: Vector2, id: int) -> void:
	box(at, Vector2(0.88, 0.88), 5, Color("6d4f39"))
	patch(at + Vector2(0.04, 0.04), Vector2(0.80, 0.80), SOIL, 6)
	for furrow in range(4):
		line3(at + Vector2(0.12, 0.16 + furrow * 0.17), at + Vector2(0.77, 0.16 + furrow * 0.17), 6, Color("a2744d"), 2)
	if id == selected_plot:
		var points := ground_rect(at - Vector2(0.06, 0.06), Vector2(1, 1), 7)
		points.append(points[0])
		draw_polyline(points, Color("ffedaf"), 4)
	# Static display stages, not timers. Rows compare readable silhouettes.
	for row in range(2):
		for col in range(2):
			var pos := at + Vector2(0.26 + col * 0.36, 0.26 + row * 0.36)
			_draw_crop(pos, id % 4, id / 4)


func _draw_crop(at: Vector2, species: int, stage: int) -> void:
	var p := project(at, 8)
	var sway := sin(clock * 1.1 + at.x * 2.0 + at.y) * 1.2
	if stage == 0:
		draw_line(p, p + Vector2(sway, -8), LEAF, 3)
		poly(PackedVector2Array([p+Vector2(sway,-4),p+Vector2(-7,-10),p+Vector2(-6,-4)]), Color("c7d787"))
		poly(PackedVector2Array([p+Vector2(sway,-4),p+Vector2(7,-11),p+Vector2(6,-4)]), LEAF)
		return
	var tall := 12.0 + stage * 2.0
	draw_line(p, p + Vector2(sway, -tall), LEAF.darkened(0.1), 3)
	for side in [-1, 1]:
		var leaf_points := PackedVector2Array([p + Vector2(0,-6), p+Vector2(side*10+sway,-tall-3),p+Vector2(side*12+sway,-7),p+Vector2(side*4,-3)])
		poly(leaf_points, LEAF if side == 1 else Color("77a65b"))
	if stage < 2:
		return
	match species:
		0:
			for dx in [-6, 4]:
				var fruit := p + Vector2(dx+sway, -9)
				draw_circle(fruit, 5, Color("c65d50"))
				draw_rect(Rect2(fruit + Vector2(-2,-2),Vector2(2,2)), Color("ffe4a2"))
		1:
			poly(PackedVector2Array([p+Vector2(-6,-5),p+Vector2(6,-5),p+Vector2(0,6)]), Color("e7a04f"))
		2:
			draw_circle(p + Vector2(0,-9), 9, Color("75a85e"))
			draw_arc(p+Vector2(0,-10), 5, 0.6, 3.3, 7, Color("b5d286"), 2)
		3:
			for dx in [-5, 4]:
				draw_circle(p+Vector2(dx,-7), 5, Color("e6c578"))


func _draw_house(at: Vector2) -> void:
	shadow(at + Vector2(0.9, 0.8), 92)
	box(at - Vector2(0.14,0.14), Vector2(2.35,1.95), 9, Color("8b8a69"))
	box(at, Vector2(2.0,1.6), 68, Color("efd5a2"), 9)
	for i in range(5):
		line3(at+Vector2(0,1.605), at+Vector2(2,1.605), 18+i*10, Color("c3a77c"), 2)
	# Gabled roof with ridge in the world x direction, vertically elevated.
	var a := project(at+Vector2(-0.2,-0.2),81)
	var b := project(at+Vector2(2.2,-0.2),81)
	var c := project(at+Vector2(2.2,1.8),81)
	var d := project(at+Vector2(-0.2,1.8),81)
	var peak_a := project(at+Vector2(-0.2,0.8),117)
	var peak_b := project(at+Vector2(2.2,0.8),117)
	poly(PackedVector2Array([a,b,peak_b,peak_a]),Color("d18a5d"),true)
	poly(PackedVector2Array([peak_a,peak_b,c,d]),Color("a95644"),true)
	poly(PackedVector2Array([b,c,peak_b]),Color("e8c58e"),true)
	for i in range(7):
		var x := -0.12 + i*0.36
		draw_line(project(at+Vector2(x,0.8),117),project(at+Vector2(x,1.8),81),Color("d48155"),2)
	box(at+Vector2(1.5,0.0),Vector2(0.28,0.3),35,Color("a67d68"),93)
	# Door and shutters on the near wall, drawn in the same projected plane.
	poly(PackedVector2Array([project(at+Vector2(0.75,1.605),10),project(at+Vector2(1.24,1.605),10),project(at+Vector2(1.24,1.605),53),project(at+Vector2(0.75,1.605),53)]),Color("725945"),true)
	for x in [0.18,1.48]:
		poly(PackedVector2Array([project(at+Vector2(x,1.61),35),project(at+Vector2(x+0.35,1.61),35),project(at+Vector2(x+0.35,1.61),56),project(at+Vector2(x,1.61),56)]),Color("688d88"),true)
		line3(at+Vector2(x,1.62),at+Vector2(x+0.35,1.62),45,CREAM,2)
	box(at+Vector2(0.65,1.7),Vector2(0.7,0.32),5,Color("b1a080"))


func _draw_tree(at: Vector2) -> void:
	shadow(at,36)
	box(at-Vector2(0.08,0.08),Vector2(0.17,0.17),50,WOOD.darkened(0.24))
	var p := project(at, 53)
	p.x += sin(clock*0.6+at.y)*1.6
	# Stepped crowns are original silhouettes, not traced pack pixels.
	var points := PackedVector2Array([Vector2(-30,9),Vector2(-39,-5),Vector2(-36,-25),Vector2(-24,-36),Vector2(-8,-42),Vector2(14,-40),Vector2(33,-28),Vector2(39,-9),Vector2(31,10),Vector2(7,19),Vector2(-14,18)])
	var crown := PackedVector2Array()
	for v in points:
		crown.append(p+v)
	poly(crown,Color("426e49"),true)
	draw_circle(p+Vector2(-8,-16),25,Color("5c9154"))
	draw_circle(p+Vector2(13,-14),22,Color("74a25e"))
	draw_circle(p+Vector2(-18,-24),17,Color("8ab66a"))
	for k in range(7):
		var spot := p+Vector2(-24+fmod(k*17.0,48),-30+fmod(k*11.0,38))
		draw_rect(Rect2(spot,Vector2(6,3)),Color("9bbf73"))
	if int(at.x+at.y) % 2 == 0:
		for offset in [Vector2(-17,0),Vector2(18,-4)]:
			draw_circle(p+offset,4,Color("d49356"))


func _draw_doghouse(at: Vector2) -> void:
	box(at,Vector2(0.65,0.65),27,Color("d7ad75"))
	poly(PackedVector2Array([project(at+Vector2(-0.1,-0.1),28),project(at+Vector2(0.75,-0.1),28),project(at+Vector2(0.75,0.75),28),project(at+Vector2(-0.1,0.75),28)]),Color("a65942"))
	var p := project(at+Vector2(0.3,0.66),10)
	draw_circle(p,9,Color("544b3c"))


func _draw_coop(at: Vector2) -> void:
	box(at,Vector2(1,0.8),36,Color("c38c59"),8)
	patch(at-Vector2(0.12,0.12),Vector2(1.24,1.04),Color("768a76"),47)
	for i in range(3):
		line3(at+Vector2(0.4,0.82+i*0.15),at+Vector2(0.75,0.82+i*0.15),25-i*7,Color("e0bc80"),5)
	var p := project(at+Vector2(0.6,0.81),24)
	draw_circle(p,9,Color("645343"))


func _draw_hive(at: Vector2) -> void:
	box(at,Vector2(0.52,0.58),28,Color("e3b75b"),10)
	for i in range(4):
		line3(at+Vector2(0,0.59),at+Vector2(0.52,0.59),15+i*6,Color("ad7b3c"),2)
	patch(at-Vector2(0.07,0.07),Vector2(0.66,0.72),Color("7c9980"),42)
	var p := project(at+Vector2(0.28,0.6),16)
	draw_rect(Rect2(p-Vector2(5,3),Vector2(10,5)),OUTLINE)
	for i in range(2):
		var bee := p+Vector2(sin(clock*1.3+i*3)*22,-20+cos(clock*1.8+i)*8)
		draw_circle(bee+Vector2(1,-3),3,CREAM)
		draw_rect(Rect2(bee,Vector2(6,3)),Color("f1ce70"))


func _draw_flowers(at: Vector2) -> void:
	for i in range(5):
		var p := project(at+Vector2(fmod(i*0.19,0.7),fmod(i*0.31,0.6)))
		draw_line(p,p-Vector2(0,10),LEAF,2)
		draw_circle(p-Vector2(0,10),4,Color("d9a498") if i%2 else CREAM)
		draw_circle(p-Vector2(0,10),1.5,Color("ddb65e"))


func _draw_animal(at: Vector2, kind: String) -> void:
	var bob := sin(clock*1.4+at.y)*0.7
	if kind == "chicken":
		shadow(at,12)
		var p := project(at, 10+bob)
		draw_line(p+Vector2(-5,4),p+Vector2(-5,12),Color("ba8546"),2)
		draw_line(p+Vector2(5,4),p+Vector2(5,12),Color("ba8546"),2)
		draw_circle(p,10,CREAM)
		draw_circle(p+Vector2(6,-7),6,Color("fff3d2"))
		draw_circle(p+Vector2(6,-13),3,Color("bb624c"))
		poly(PackedVector2Array([p+Vector2(10,-8),p+Vector2(17,-5),p+Vector2(10,-3)]),Color("d6a24f"))
		draw_rect(Rect2(p+Vector2(7,-9),Vector2(2,2)),OUTLINE)
		return
	var body := Vector2(0.7,0.36) if kind == "cow" else Vector2(0.45,0.23)
	var height := 19.0 if kind == "cow" else 12.0
	var color := CREAM if kind == "cow" else Color("c59c69")
	shadow(at,23 if kind == "cow" else 16)
	for foot in [Vector2(0.05,0.05),Vector2(body.x-0.1,0.05),Vector2(0.05,body.y-0.05),body-Vector2(0.1,0.05)]:
		box(at+foot,Vector2(0.06,0.06),12,Color("765943"))
	box(at,body,height,color,12+bob)
	box(at+Vector2(body.x-0.02,-0.05),Vector2(0.23,0.32),height*0.8,color.darkened(0.06),17+bob)
	if kind == "cow":
		patch(at+Vector2(0.1,0.04),Vector2(0.24,0.2),Color("855f45"),32+bob)
		box(at+Vector2(body.x+0.1,-0.07),Vector2(0.18,0.12),4,Color("e0a994"),16+bob)
	else:
		var tail := project(at,23+bob)
		draw_line(tail,tail+Vector2(-12,-6+sin(clock*3)*4),Color("8d6948"),4)
		box(at+Vector2(body.x,0.02),Vector2(0.09,0.11),9,Color("6e5944"),26+bob)
	var eye := project(at+Vector2(body.x+0.14,body.y),29+bob)
	draw_rect(Rect2(eye,Vector2(3,3)),OUTLINE)


func _fence(a: Vector2, b: Vector2, count: int) -> void:
	for rail in [10,21]:
		line3(a,b,rail,Color("d6bd8b"),4)
	for i in range(count+1):
		var at := a.lerp(b,float(i)/count)
		box(at,Vector2(0.045,0.045),27,Color("e3c893"))


func _draw_fences() -> void:
	_fence(Vector2(-1.1,8.7),Vector2(0.7,8.7),3)
	_fence(Vector2(2.2,8.7),Vector2(10.6,8.7),14)
	_fence(Vector2(5.5,-0.1),Vector2(7.3,-0.1),4)
	_fence(Vector2(7.3,-0.1),Vector2(7.3,1.4),3)


func _draw_air() -> void:
	# Ambient chimney puffs, no imported VFX.
	var base := project(Vector2(1.6,0.1),133)
	for i in range(3):
		var phase := fmod(clock*0.22+i*0.33,1.0)
		draw_circle(base+Vector2(phase*23,-phase*50),5+phase*6,Color(0.98,0.94,0.80,(1-phase)*0.3))
	for i in range(5):
		var p := project(Vector2(2+i*0.6,8.5),20)+Vector2(sin(clock+i)*12,cos(clock*0.7+i)*6)
		var wing := 2+absf(sin(clock*3+i))*3
		draw_line(p,p+Vector2(-wing,-3),Color("f0d6a0"),2)
		draw_line(p,p+Vector2(wing,-3),Color("f0d6a0"),2)
