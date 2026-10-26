extends "res://scripts/visual/g12_view.gd"
## Textured masks adapt authored soil; no new procedural illustration or final-art claim.
var terrain: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/g14/terrain.json"))

func configure() -> void:
	var occupied := Rect2(-150,-160,310,280)
	for plot in demo.plots:
		occupied = occupied.merge(Rect2(project(Grid.vec(plot.grid))-Vector2(40,24),Vector2(80,56)))
	definition.focus_bounds = [occupied.position.x,occupied.position.y,occupied.size.x,occupied.size.y]
	definition.camera_bounds = [occupied.position.x-60,occupied.position.y-60,occupied.end.x+60,occupied.end.y+60]
	definition.paths = []
	for i in range(-2,7):
		definition.paths.append([-2,i])
		definition.paths.append([i,-2])
		definition.paths.append([6,i])
		definition.paths.append([i,6])
	definition.fences = []
	for i in range(-1,6,2):
		definition.fences.append({"id":"land.fence.x."+str(i),"kind":"fence_x","at":[i,7]})
		definition.fences.append({"id":"land.fence.y."+str(i),"kind":"fence_y","at":[7,i]})
	definition.entities = definition.entities.filter(func(row: Dictionary) -> bool: return row.kind!="chicken")
	for row in definition.entities:
		if row.id=="rocks.east":
			row.at = [8,2]
		elif row.id=="bush.front":
			row.at = [8,6]
		elif row.id=="flowers.front":
			row.at = [4,8]
	definition.door_path = [[21,-50],[23,-43],[26,-36],[29,-29],[32,-22]]

func neighbor(index: int, offset: Array) -> int:
	var at: Array = demo.plots[index].grid
	for i in range(demo.plots.size()):
		if demo.plots[i].grid[0]==at[0]+offset[0] and demo.plots[i].grid[1]==at[1]+offset[1]:
			return i
	return -1

func textured(points: Array, uv_pixels: Array, at: Vector2, tint: Color) -> void:
	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	for i in range(points.size()):
		vertices.append(at+Grid.vec(points[i]))
		uvs.append(Grid.vec(uv_pixels[i])/CROPS.get_size())
	draw_polygon(vertices,PackedColorArray([tint]),uvs,CROPS)

func soil(index: int, at: Vector2, locked: bool) -> void:
	var tint := Color("849766") if locked else Color.WHITE
	if index==hover_id:
		tint = tint.lightened(0.16)
	textured(terrain.floor_points,terrain.floor_uv,at,tint)
	for edge in terrain.edges:
		var other: int = neighbor(index,edge.neighbor)
		if other<0 or (not locked and demo.plots[other].state=="locked"):
			textured(edge.points,edge.uv,at,Color("8a9c83") if locked else Color.WHITE)

func plot(id: int) -> void:
	var at := plot_center(id)
	var state: Dictionary = demo.plots[id]
	var locked: bool = state.state=="locked"
	soil(id,at,locked)
	if locked:
		var bush: Dictionary = definition.kit.bush.duplicate(true)
		bush.size = [20,15]
		bush.pivot = [10,13]
		sprite(KIT,bush,at+Vector2(-10,2),Color("b0baa2"))
		draw_string(ThemeDB.fallback_font,at+Vector2(4,4),state.short_label+"+",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("fff2d5"))
		return
	if not state.key.is_empty():
		for socket in definition.seed_sockets:
			sprite(CROPS,definition.crops[state.key],at+Grid.vec(socket))
	if not state.crop_id.is_empty():
		if state.care.weeds:
			sprite(CARE,care_art.weeds,at+Vector2(-20,6))
		if state.care.pests:
			sprite(CARE,care_art.pests,at+Vector2(20,6))
		if state.care.needs_water:
			sprite(UI,{"rect":[1040,565,465,390],"size":[12,10],"pivot":[6,9]},at+Vector2(0,10))
	if state.state=="mature":
		sprite(FX,definition.fx.reward,at+Vector2(24,-16))

func feedback(id: int, action: String) -> void:
	super.feedback(id,"harvest" if action=="unlock_plot" else action)
