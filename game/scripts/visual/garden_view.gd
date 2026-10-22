extends "res://scripts/visual/farm_study.gd"
## G0.4 original pixel-shaped garden, preserving the G0.3 renderer unmodified.

var demo: RefCounted
var effects: Array[Dictionary] = []
var draw_accumulator: float = 0
var hover_plot: int = -1


func _ready() -> void:
	super._ready()
	fixture.objects.append_array([
		{"kind":"tree","position":[9.1,7.1]},
		{"kind":"tree","position":[9.5,0.1]},
		{"kind":"flowers","position":[0.8,2.0]},
		{"kind":"flowers","position":[7.4,6.5]},
		{"kind":"flowers","position":[-0.1,4.5]}
	])


func _process(delta: float) -> void:
	if animation_enabled:
		clock += delta
	for effect in effects:
		effect.age += delta
	effects = effects.filter(func(e: Dictionary) -> bool: return e.age<0.9)
	draw_accumulator += delta
	if draw_accumulator>=1.0/30.0 and (animation_enabled or not effects.is_empty()):
		draw_accumulator = 0
		queue_redraw()


func feedback(id: int, action: String) -> void:
	if effects.size()>=32:
		effects.pop_front()
	effects.append({"id":id,"action":action,"age":0.0})
	queue_redraw()


func _draw() -> void:
	super._draw()
	for effect in effects:
		var id: int = effect.id
		var at := Vector2(2.7+(id%4)*1.06+0.44,3.0+(id/4)*1.06+0.44)
		var origin := project(at,20)
		var age: float = effect.age
		var color := Color("ffd47c") if effect.action=="harvest" else Color("8cceef") if effect.action=="water" else Color("c4e88c")
		color.a = 1.0-age/0.9
		if animation_enabled:
			for i in range(8):
				var angle := i*TAU/8
				var p := origin+Vector2(cos(angle)*age*42,sin(angle)*age*24-age*33)
				draw_rect(Rect2(p,Vector2(4,4)),color)
		var ring := ground_rect(at-Vector2(0.42,0.42),Vector2(0.84,0.84),7)
		ring.append(ring[0])
		draw_polyline(ring,color,3)


func _draw_ground() -> void:
	# Continuous meadow, not an isolated floating board.
	patch(Vector2(-35,-35),Vector2(80,80),Color("729c59"),-3)
	patch(Vector2(-2.3,-2.3),Vector2(15,13.6),Color("91b969"),-2)
	for i in range(500):
		var at := Vector2(-4+fmod(i*0.773,19.0),-4+fmod(i*1.413,17.0))
		if Rect2(2.5,2.8,4.7,4.7).has_point(at):
			continue
		patch(at,Vector2(0.07,0.035),Color("a4c879") if i%2 else Color("7fa457"))
		if i%13==0:
			var p := project(at)
			draw_line(p,p+Vector2(0,-5),Color("628c4f"),2)
			if i%26==0:
				draw_rect(Rect2(p+Vector2(-2,-7),Vector2(4,3)),Color("fae4a0"))
	# Distant orchard silhouettes continue beyond the fence.
	for i in range(11):
		_draw_tree(Vector2(-3.0+i*1.7,-3.0))
	for i in range(8):
		_draw_tree(Vector2(-3.2,0.5+i*1.6))


func _draw_expansion() -> void:
	# A future meadow becomes a decorative pond/orchard, without an unlock system.
	patch(Vector2(8.0,3.1),Vector2(2.3,2.1),Color("c9b983"))
	patch(Vector2(8.15,3.24),Vector2(2.0,1.83),Color("5c9f9c"))
	patch(Vector2(8.35,3.42),Vector2(1.6,1.4),Color("72b5b0"))
	for i in range(4):
		var offset := sin(clock*0.8+i)*0.06
		line3(Vector2(8.5+offset,3.7+i*0.29),Vector2(9.2+offset,3.7+i*0.29),1,Color("b0d5b3"),2)
	for i in range(9):
		var at := Vector2(7.9+fmod(i*0.73,2.6),3.0+fmod(i*0.57,2.4))
		if i%2==0:
			box(at,Vector2(0.12,0.12),6,Color("bcb790"))
	_draw_flowers(Vector2(8.3,6.3))
	_draw_flowers(Vector2(9.4,6.3))
	# Bench and stacked produce crates.
	box(Vector2(8.5,1.7),Vector2(0.9,0.28),8,Color("c99459"),14)
	box(Vector2(8.5,1.9),Vector2(0.9,0.06),15,Color("ae784a"),20)
	for at in [Vector2(7.6,7.5),Vector2(8.0,7.5)]:
		box(at,Vector2(0.32,0.34),19,Color("d0a260"))
		for j in range(3):
			line3(at,at+Vector2(0.32,0),5+j*5,Color("8d653f"),2)


func _draw_house(at: Vector2) -> void:
	super._draw_house(at)
	# Hand-laid terracotta roof, warm windows, teal shutters and flowering boxes.
	for row in range(5):
		var v := 0.85+row*0.18
		var h := 115.0-row*6.5
		line3(at+Vector2(-0.12,v),at+Vector2(2.15,v),h,Color("e5a068"),2)
	for x in [0.18,1.48]:
		poly(PackedVector2Array([project(at+Vector2(x,1.63),36),project(at+Vector2(x+0.35,1.63),36),project(at+Vector2(x+0.35,1.63),54),project(at+Vector2(x,1.63),54)]),Color("f5cf78"))
		for dx in [-0.08,0.36]:
			poly(PackedVector2Array([project(at+Vector2(x+dx,1.63),35),project(at+Vector2(x+dx+0.07,1.63),35),project(at+Vector2(x+dx+0.07,1.63),55),project(at+Vector2(x+dx,1.63),55)]),Color("508e84"))
		box(at+Vector2(x-0.03,1.7),Vector2(0.42,0.16),8,Color("a36546"),23)
		for i in range(4):
			var p := project(at+Vector2(x+i*0.1,1.76),34)
			draw_rect(Rect2(p,Vector2(4,4)),Color("e68b8c") if i%2 else Color("f1d986"))
	var door := project(at+Vector2(1.14,1.64),31)
	draw_rect(Rect2(door,Vector2(3,3)),Color("f0cc76"))
	# Little porch posts and welcome path.
	box(at+Vector2(0.6,1.95),Vector2(0.06,0.06),31,Color("d7b783"))
	box(at+Vector2(1.38,1.95),Vector2(0.06,0.06),31,Color("d7b783"))
	patch(at+Vector2(0.55,1.69),Vector2(0.93,0.45),Color("5c8c78"),43)


func _draw_tree(at: Vector2) -> void:
	shadow(at,38)
	box(at-Vector2(0.07,0.07),Vector2(0.15,0.15),50,Color("886440"))
	var p := project(at,57).round()
	p.x += round(sin(clock*0.6+at.y))
	var variant := posmod(int(at.x*7+at.y*3),3)
	if variant==1:
		for i in range(3):
			var half := 29.0-i*7
			var y := -float(i)*18
			poly(PackedVector2Array([p+Vector2(-half,y),p+Vector2(-half+8,y-14),p+Vector2(0,y-33),p+Vector2(half-8,y-14),p+Vector2(half,y)]),Color("3e7751") if i%2==0 else Color("5a955c"),true)
		return
	var palette := [Color("356d49"),Color("508b50"),Color("72a957"),Color("a0c86a")]
	for layer in range(4):
		var origin := p+Vector2(-35+layer*6,-28-layer*5)
		var w := 65-layer*10
		var crown := PackedVector2Array([origin+Vector2(7,0),origin+Vector2(w-9,0),origin+Vector2(w-9,5),origin+Vector2(w,5),origin+Vector2(w,27),origin+Vector2(w-7,27),origin+Vector2(w-7,37),origin+Vector2(4,37),origin+Vector2(4,31),origin+Vector2(-3,31),origin+Vector2(-3,8),origin+Vector2(7,8)])
		poly(crown,palette[layer])
	if variant==2:
		for offset in [Vector2(-19,0),Vector2(15,-10),Vector2(1,7)]:
			draw_rect(Rect2(p+offset,Vector2(6,6)),Color("e9a355"))
	for i in range(8):
		draw_rect(Rect2(p+Vector2(-20+fmod(i*17,42),-31+fmod(i*13,43)),Vector2(5,3)),Color("bbd580"))


func _draw_plot(at: Vector2, id: int) -> void:
	if demo==null:
		return
	var plot: Dictionary = demo.plots[id]
	var wet: bool = plot.state=="growing"
	shadow(at+Vector2(0.42,0.42),31)
	box(at,Vector2(0.94,0.94),8,Color("c5925c"))
	patch(at+Vector2(0.055,0.055),Vector2(0.83,0.83),Color("775240") if wet else Color("976447"),9)
	for i in range(4):
		line3(at+Vector2(0.12,0.18+i*0.18),at+Vector2(0.82,0.18+i*0.18),9,Color("80563c") if wet else Color("b37d50"),2)
	if id==hover_plot or id==selected_plot or plot.state=="mature":
		var outline := ground_rect(at,Vector2(0.94,0.94),10)
		outline.append(outline[0])
		draw_polyline(outline,Color("f9de8c") if id==hover_plot or id==selected_plot else Color("d5b66e"),2)
	if plot.state!="empty":
		var species: int = demo.config.seeds[plot.seed].species
		for row in range(2):
			for col in range(2):
				_draw_crop(at+Vector2(0.28+col*0.37,0.27+row*0.37),species,3 if plot.state=="mature" else 1)
	var p := project(at+Vector2(0.5,0.5),39)
	if plot.state=="needs_water":
		poly(PackedVector2Array([p+Vector2(0,-9),p+Vector2(-5,0),p+Vector2(-4,5),p+Vector2(4,5),p+Vector2(5,0)]),Color("8ad5e9"),true)
	elif plot.state=="mature":
		var pulse := sin(clock*1.5+id)*1.5
		draw_line(p+Vector2(-4,-8+pulse),p+Vector2(4,-8+pulse),Color("ffe8a7"),2)
		draw_line(p+Vector2(0,-12+pulse),p+Vector2(0,-4+pulse),Color("ffe8a7"),2)
	elif plot.state=="empty":
		var center := project(at+Vector2(0.47,0.47),12)
		draw_line(center-Vector2(4,0),center+Vector2(4,0),Color("d0a274"),2)
		draw_line(center-Vector2(0,3),center+Vector2(0,3),Color("d0a274"),2)


func _draw_crop(at: Vector2, species: int, stage: int) -> void:
	super._draw_crop(at,species,stage)
	if stage>=2:
		var p := project(at,17)
		if species==0:
			for dx in [-6,4]:
				poly(PackedVector2Array([p+Vector2(dx-4,-3),p+Vector2(dx+4,-3),p+Vector2(dx+4,2),p+Vector2(dx,7),p+Vector2(dx-4,2)]),Color("e77766"))
		elif species==1:
			draw_rect(Rect2(p+Vector2(-3,4),Vector2(6,5)),Color("f2ac51"))
