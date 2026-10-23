extends Node2D
## Independent authored-sprite sample; no legacy renderer or procedural world art.

const ENV = preload("res://assets/art/g05r_pilot/environment_v1.png")
const CROPS = preload("res://assets/art/g05r_pilot/crops_fx_v1.png")
const UI = preload("res://assets/art/g05r_pilot/ui_v1.png")
const QUIET_GRASS = preload("res://assets/art/g05/terrain_atlas_v1.png")
const TREE = preload("res://assets/art/g05r_pilot/tree_v2.png")
var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/pilot/sample_v2.json"))
var demo: RefCounted
var effects: Array[Dictionary] = []
var clock: float = 0
var motion: bool = true
var hover_id: int = -1

func project(point: Vector2) -> Vector2:
	return Vector2((point.x-point.y)*16,(point.x+point.y)*8)

func _process(delta: float) -> void:
	if motion:
		clock += delta
	for effect in effects:
		effect.age += delta
	effects = effects.filter(func(effect: Dictionary) -> bool: return effect.age<0.7)
	queue_redraw()

func frame_at(durations: Array, elapsed: float) -> int:
	for i in range(durations.size()):
		elapsed -= float(durations[i])
		if elapsed<0:
			return i
	return durations.size()-1

func sprite(texture: Texture2D, item: Dictionary, at: Vector2, tint: Color = Color.WHITE) -> void:
	var r: Array = item.rect
	var size := Vector2(item.size[0],item.size[1])
	var pivot := Vector2(item.pivot[0],item.pivot[1])
	draw_texture_rect_region(texture,Rect2((at-pivot).round(),size),Rect2(r[0],r[1],r[2],r[3]),tint)

func environment(key: String, point: Vector2) -> void:
	sprite(TREE if key=="tree" else ENV,definition.env[key],project(point))

func plot_center(id: int) -> Vector2:
	var point: Array = definition.plot_positions[id]
	return project(Vector2(point[0],point[1]))

func feedback(id: int, action: String) -> void:
	if effects.size()>=16:
		effects.pop_front()
	effects.append({"id":id,"action":action,"age":0.0,"seed":demo.plots[id].seed})

func _draw() -> void:
	if demo==null:
		return
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	draw_texture_rect(QUIET_GRASS,Rect2(-4000,-4000,8000,8000),true,Color(1.04,1.08,0.95))
	for point in [Vector2(-2,-1),Vector2(-2,2),Vector2(-2,5),Vector2(1,5),Vector2(4,5)]:
		environment("path",point)
	environment("tree",Vector2(3,-3))
	environment("house",Vector2(-3,-3))
	environment("tree",Vector2(-4,2))
	environment("fence",Vector2(6,0))
	var order := [0,1,2,3]
	order.sort_custom(func(a: int,b: int) -> bool: return plot_center(a).y<plot_center(b).y)
	for id in order:
		var at := plot_center(id)
		var plot: Dictionary = demo.plots[id]
		var tint := Color("c1d3d4") if plot.state=="needs_water" else Color.WHITE
		if id==hover_id:
			tint = Color(1.08,1.08,1.0)
		sprite(CROPS,definition.crops.soil,at,tint)
		if plot.state!="empty":
			var crop := "strawberry" if plot.seed==0 else "carrot"
			var stage := "mature" if plot.state=="mature" else "growing" if plot.state=="growing" and plot.seed==1 else "seed"
			var key := crop+"_"+stage
			for socket in definition.seed_sockets:
				sprite(CROPS,definition.crops[key],at+Vector2(socket[0],socket[1]))
		if plot.state=="needs_water":
			sprite(UI,{"rect":[1040,565,465,390],"size":[12,10],"pivot":[6,9]},at+Vector2(0,8))
	var durations: Array = definition.chicken_durations
	var total := 0.0
	for duration in durations:
		total += float(duration)
	var frame := frame_at(durations,fmod(clock,total))
	environment("chicken_"+str(frame),Vector2(-2,4))
	environment("flowers",Vector2(4,5))
	for effect in effects:
		var at := plot_center(effect.id)-Vector2(0,16)
		if motion:
			at.y -= effect.age*8
		if effect.action=="harvest":
			var fx := frame_at(definition.harvest_durations,effect.age)
			if effect.seed==1:
				fx = maxi(1,fx)
			sprite(CROPS,definition.crops["harvest_"+str(fx)],at,Color(1,1,1,minf(1,(0.7-effect.age)*4)))
		elif effect.action=="plant":
			sprite(CROPS,definition.crops.carrot_seed,at,Color(1,1,1,1-effect.age/0.7))
		else:
			sprite(UI,{"rect":[1040,565,465,390],"size":[22,18],"pivot":[11,9]},at,Color(1,1,1,1-effect.age/0.7))
