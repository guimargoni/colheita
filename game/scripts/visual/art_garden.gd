extends "res://scripts/visual/garden_view.gd"
## Sprite-only art study. The inherited geometric renderer is never called here.

const ENV = preload("res://assets/art/g05/environment_atlas_v1.png")
const CROPS = preload("res://assets/art/g05/crops_atlas_v1.png")
const UI_ATLAS = preload("res://assets/art/g05/ui_atlas_v1.png")
const TERRAIN_TEXTURE = preload("res://assets/art/g05/terrain_atlas_v1.png")
const POSITIONS = [Vector2(2.7,2.5),Vector2(4.5,2.5),Vector2(2.7,4.3),Vector2(4.5,4.3)]
var animal_atlas: Texture2D
var halloween: bool = false
var before: bool = false
var regions: Dictionary

func _ready() -> void:
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	regions = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/sample.json")).regions
	if ResourceLoader.exists("res://assets/art/g05/animals_atlas_v1.png"):
		animal_atlas = load("res://assets/art/g05/animals_atlas_v1.png")
	fixture = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE_PATH))

func project(point: Vector2, height: float = 0) -> Vector2:
	return Vector2((point.x-point.y)*64,(point.x+point.y)*32-height)

func unproject(point: Vector2) -> Vector2:
	return Vector2((point.x/64+point.y/32)/2,(point.y/32-point.x/64)/2)

func sprite(texture: Texture2D, source: Rect2, at: Vector2, size: Vector2, pivot: Vector2 = Vector2(0.5,0.9), tint: Color = Color.WHITE) -> void:
	draw_texture_rect_region(texture,Rect2(at-size*pivot,size),source,tint)

func environment(key: String, at: Vector2, size: Vector2, tint: Color = Color.WHITE) -> void:
	var r: Array = regions[key]
	sprite(ENV,Rect2(r[0],r[1],r[2],r[3]),project(at),size,Vector2(0.5,0.91),tint)

func _draw() -> void:
	if regions.is_empty() or demo==null:
		return
	if before:
		_draw_ground()
		_draw_paths()
	else:
		# Authored quiet ground; continuous texture, no procedural tile art.
		draw_texture_rect(TERRAIN_TEXTURE,Rect2(-6000,-6000,12000,12000),true)
		for p in [Vector2(0,1),Vector2(1,1),Vector2(1,2),Vector2(1,3),Vector2(1,4),Vector2(1,5),Vector2(2,5),Vector2(3,5),Vector2(4,5),Vector2(5,5)]:
			environment("path",p,Vector2(145,86))
	var objects: Array[Dictionary] = [
		{"kind":"house","p":Vector2(-0.5,0)},
		{"kind":"tree","p":Vector2(-2,-1.5)},
		{"kind":"tree","p":Vector2(4.8,-1.8)},
		{"kind":"tree","p":Vector2(-0.7,4.6)},
		{"kind":"fence","p":Vector2(4.7,-0.3)},
		{"kind":"fence","p":Vector2(6.4,1.4)},
		{"kind":"flowers","p":Vector2(0.2,1.2)},
		{"kind":"flowers","p":Vector2(5.5,5.6)},
		{"kind":"dog","p":Vector2(0.5,2.1)},
		{"kind":"chicken","p":Vector2(2.3,6.4)}
	]
	for id in range(4):
		objects.append({"kind":"plot","p":POSITIONS[id],"id":id})
	objects.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.p.x+a.p.y<b.p.x+b.p.y)
	for item in objects:
		var p: Vector2 = item.p
		if item.kind=="plot":
			art_plot(item.id,p)
		elif item.kind in ["chicken","dog"]:
			animal(item.kind,p)
		elif before:
			match item.kind:
				"house": _draw_house(p)
				"tree": _draw_tree(p)
				"flowers": _draw_flowers(p)
				"fence": line3(project(p),project(p+Vector2(1.5,0)),16,Color("785d38"),8)
		else:
			var size: Vector2 = {"house":Vector2(300,300),"tree":Vector2(208,247),"fence":Vector2(260,156),"flowers":Vector2(133,82)}[item.kind]
			environment(item.kind,p,size)
	for effect in effects:
		if effect.id>=4 or animal_atlas==null:
			continue
		var at := project(POSITIONS[effect.id],35+(effect.age*25 if animation_enabled else 0))
		var column: int = {"plant":0,"water":1,"harvest":2}[effect.action]
		var tint := Color(1,1,1,1-effect.age/0.9)
		sprite(animal_atlas,Rect2(column*384,790,384,234),at,Vector2(135,82),Vector2(0.5,0.5),tint)
		if effect.action=="harvest":
			sprite(animal_atlas,Rect2(1152,790,384,234),at+Vector2(0,-20),Vector2(95,58),Vector2(0.5,0.5),tint)
			if halloween and effect.id==3:
				sprite(animal_atlas,Rect2(384,790,384,234),at,Vector2(110,67),Vector2(0.5,0.5),Color(0.7,1,0.9,tint.a))

func art_plot(id: int, p: Vector2) -> void:
	var plot: Dictionary = demo.plots[id]
	if before:
		_draw_plot(p,id)
		return
	var row: int = 1-int(plot.seed)
	var col: int = 0
	if plot.state=="empty":
		row = 0
	elif plot.state=="needs_water":
		col = 1 if row==0 else 0
	elif plot.state=="growing":
		col = 2 if row==0 else 1
	elif plot.state=="mature":
		col = 3 if row==0 else 2
		if row==1 and animation_enabled and fmod(clock,3)>2.7:
			col = 3
	if halloween and id==3:
		row = 2
		col = 2+int(fmod(clock,4.0)>3.75) if plot.state=="mature" else 1 if plot.state=="growing" else 0
	var tint := Color("d6edff") if plot.state=="needs_water" else Color.WHITE
	if halloween and id==3 and plot.state=="mature":
		tint = Color(1.04+0.04*sin(clock*2),1.04+0.04*sin(clock*2),1.0)
	if id==hover_plot or id==selected_plot:
		tint = Color(1.1,1.08,1.0)
	sprite(CROPS,Rect2(col*384,row*341,384,341),project(p),Vector2(211,187),Vector2(0.5,0.84),tint)
	if plot.state=="mature" and animal_atlas!=null:
		sprite(UI_ATLAS,Rect2(795,740,220,220),project(p,102),Vector2(38,38),Vector2(0.5,0.5))

func animal(kind: String, p: Vector2) -> void:
	if before:
		_draw_animal(p,kind)
		return
	if animal_atlas==null:
		return
	var walking := kind=="chicken" and fmod(clock,8)>4
	var row := 1 if walking else 0 if kind=="chicken" else 2
	var col := int(clock*(6 if walking else 2))%4
	var offset := Vector2(sin(clock*0.8)*12,0) if walking else Vector2.ZERO
	var source: Rect2
	if row==0:
		source = Rect2([130,488,846,1195][col],20,220,236)
	elif row==1:
		source = Rect2([130,488,846,1195][col],280,235,220)
	else:
		source = Rect2([100,455,815,1175][col],512,255,266)
	sprite(animal_atlas,source,project(p)+offset,Vector2(60,64) if kind=="chicken" else Vector2(95,99))
