extends Node2D
## Authored textured world; structural positions are logical ground coordinates.

const Grid = preload("res://scripts/visual/g06_grid.gd")
const ENV = preload("res://assets/art/g05r_pilot/environment_v1.png")
const CROPS = preload("res://assets/art/g05r_pilot/crops_fx_v1.png")
const UI = preload("res://assets/art/g05r_pilot/ui_v1.png")
const TREE = preload("res://assets/art/g05r_pilot/tree_v2.png")
const GRASS = preload("res://assets/art/g05/terrain_atlas_v1.png")
const KIT = preload("res://assets/art/g06/garden_kit_v1.png")
const FX = preload("res://assets/art/g06/action_fx_v1.png")
const PATH = preload("res://assets/art/g06/path_v2.png")
var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/g06/reference.json"))
var demo: RefCounted
var effects: Array[Dictionary] = []
var clock: float = 0
var motion: bool = true
var hover_id: int = -1

func project(point: Vector2) -> Vector2:
	return Grid.project(point)

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
	draw_texture_rect_region(texture,Rect2((at-Grid.vec(item.pivot)).round(),Grid.vec(item.size)),Rect2(r[0],r[1],r[2],r[3]),tint)

func environment(key: String, at: Vector2) -> void:
	if key=="path":
		sprite(PATH,definition.path_tile,at)
	elif definition.kit.has(key):
		sprite(KIT,definition.kit[key],at)
	else:
		sprite(TREE if key=="tree" else ENV,definition.env[key],at)

func plot_center(id: int) -> Vector2:
	return project(Grid.vec(definition.plot_positions[id]))

func feedback(id: int, action: String) -> void:
	if effects.size()>=16:
		effects.pop_front()
	effects.append({"id":id,"action":action,"age":0.0})

func plot(id: int) -> void:
	var at := plot_center(id)
	var state: Dictionary = demo.plots[id]
	var tint := Color("b7c8cb") if state.state=="needs_water" else Color.WHITE
	if id==hover_id:
		tint = Color(1.08,1.08,1)
	sprite(CROPS,definition.crops.soil,at,tint)
	if state.state!="empty":
		var crop := "strawberry" if state.seed==0 else "carrot"
		var stage := "mature" if state.state=="mature" else "growing" if state.state=="growing" and state.seed==1 else "seed"
		for socket in definition.seed_sockets:
			sprite(CROPS,definition.crops[crop+"_"+stage],at+Grid.vec(socket))
	if state.state=="needs_water":
		sprite(UI,{"rect":[1040,565,465,390],"size":[12,10],"pivot":[6,9]},at+Vector2(0,8))

func draw_effects() -> void:
	for effect in effects:
		var at := plot_center(effect.id)-Vector2(0,12)
		if motion:
			at.y -= effect.age*7
		var key: String = effect.action
		if key=="harvest":
			key = "harvest_a" if effect.age<0.12 else "harvest_b" if effect.age<0.3 else "reward"
		var opacity := minf(1,(0.7-effect.age)*4)
		sprite(FX,definition.fx[key],at,Color(1,1,1,opacity))

func _draw() -> void:
	if demo==null:
		return
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	draw_texture_rect(GRASS,Rect2(-4000,-4000,8000,8000),true,Color(1.02,1.04,0.92))
	texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	for point in definition.paths:
		environment("path",project(Grid.vec(point)))
	for point in definition.door_path:
		environment("path",Grid.vec(point))
	var order: Array = definition.entities.duplicate(true)
	order.append_array(definition.fences)
	for id in range(4):
		order.append({"id":"plot."+str(id),"kind":"plot","at":definition.plot_positions[id],"plot":id})
	order.sort_custom(Grid.depth_before)
	for entity in order:
		if entity.kind=="plot":
			plot(entity.plot)
		else:
			var key: String = entity.kind
			if key=="chicken":
				var durations: Array = definition.chicken_durations
				key = "chicken_"+str(frame_at(durations,fmod(clock,3.07)))
			environment(key,project(Grid.vec(entity.at)))
	draw_effects()
