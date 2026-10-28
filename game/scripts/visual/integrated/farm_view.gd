extends "res://scripts/visual/g1v/living_view.gd"
const DECOR = preload("res://assets/art/integrated/decor_v1.png")
const ANIMALS = preload("res://assets/art/integrated/animals_v1.png")
var animations: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/integrated/animals_animation.json"))
const PAINT = preload("res://assets/art/integrated/environment_v1.png")
const PLANTS = preload("res://assets/art/integrated/crops_v1.png")
const MEADOW = preload("res://assets/art/integrated/meadow_v1.png")
const F = preload("res://scripts/domain/integrated/features.gd")
var art: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/integrated/art.json"))
var producer_points: Dictionary = {}
var background: Sprite2D
var animal_reactions: Dictionary = {}
func configure() -> void:
	super.configure()
	background = Sprite2D.new()
	background.texture = MEADOW
	background.show_behind_parent = true
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/visual/integrated/meadow.gdshader")
	background.material = material
	add_child(background)
	definition.entities = definition.entities.filter(func(e: Dictionary) -> bool: return e.kind!="chicken")
	definition.fences = []
	definition.focus_bounds = [-205,-210,410,390]
	definition.camera_bounds = [-320,-260,320,260]
func painted(texture: Texture2D, item: Dictionary, at: Vector2, tint: Color = Color.WHITE, angle: float = 0.0) -> void:
	var r: Array = item.rect
	draw_set_transform(at,angle)
	draw_texture_rect_region(texture,Rect2(-Grid.vec(item.pivot),Grid.vec(item.size)),Rect2(r[0],r[1],r[2],r[3]),tint)
	draw_set_transform(Vector2.ZERO)
func crop_key(id: String, state: String) -> String:
	var species: String = id.trim_prefix("crop.").replace("haunted_pumpkin","pumpkin")
	return species+"_mature" if state=="mature" else species+"_growing"
func crop_texture(id: String, state: String) -> Texture2D:
	var item: Dictionary = art.crops.get(crop_key(id,state),art.crops.seed)
	var rect: Array = item.rect
	var texture := AtlasTexture.new()
	texture.atlas = PLANTS
	texture.region = Rect2(rect[0],rect[1],rect[2],rect[3])
	return texture
func environment(key: String, at: Vector2) -> void:
	var mapped: String = "pine" if key=="cypress" else "bush" if key in ["flowers","grass","rocks"] else key
	if art.environment.has(mapped):
		painted(PAINT,art.environment[mapped],at,Color.WHITE,sin(clock*0.8+at.x*0.04)*0.007*intensity if motion and mapped in ["tree","pine","bush"] else 0.0)
func plot(id: int) -> void:
	var at := plot_center(id)
	var p: Dictionary = demo.plots[id]
	painted(PLANTS,art.crops.soil,at,Color(0.60,0.67,0.55) if p.state=="locked" else Color.WHITE.lightened(0.12) if id==hover_id else Color.WHITE)
	if p.state=="locked":
		draw_string(ThemeDB.fallback_font,at+Vector2(-10,3),p.short_label+"+",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("fff6de"))
		return
	if p.crop_id.is_empty(): return
	var key: String = "seed" if p.stage==0 and p.state!="mature" else crop_key(p.crop_id,p.state)
	var sway: float = sin(clock*1.6+id*1.87)*0.025*intensity if motion else 0.0
	var spring: float = springs.get(id,0.0)
	sway += sin((0.4-spring)*23)*spring*0.05*intensity if motion and spring>0 else 0.0
	var tint := Color.WHITE
	if p.state=="mature" and motion:
		tint = tint.lerp(Color(1.1,1.06,0.97),maxf(0,sin(clock+id))*0.35*intensity)
	painted(PLANTS,art.crops.get(key,art.crops.seed),at,tint,sway)
	if p.care.needs_water:
		draw_circle(at+Vector2(21,-12),3,Color("60c9e3"))
	if p.care.weeds:
		draw_string(ThemeDB.fallback_font,at+Vector2(-28,-8),"Ervas",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("5b782e"))
	if p.care.pests:
		draw_string(ThemeDB.fallback_font,at+Vector2(12,-8),"Praga",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("a5574e"))
func draw_effects() -> void:
	# Existing bounded analytical particles/reward text, with newly painted crop ghosts.
	var old_ghosts: Array[Dictionary] = ghosts
	ghosts = []
	super.draw_effects()
	ghosts = old_ghosts
	if motion and intensity>0:
		for g in ghosts:
			var key: String = crop_key(g.state.crop_id,"mature")
			painted(PLANTS,art.crops.get(key,art.crops.seed),plot_center(g.id)-Vector2(0,g.age*20),Color(1,1,1,1-g.age/0.38))
func _draw() -> void:
	if demo==null: return
	for point in definition.door_path:
		var path_item: Dictionary = art.decor.path.duplicate(true)
		path_item.size = [22,12]; path_item.pivot = [11,6]
		painted(DECOR,path_item,Grid.vec(point))
	var f: Dictionary = demo.service.state.get("features",{})
	var rows: Array = []
	for e in definition.entities: rows.append({"type":"environment","at":project(Grid.vec(e.at)),"kind":e.kind})
	for id in range(demo.plots.size()): rows.append({"type":"plot","at":plot_center(id),"id":id})
	for item in f.get("decorations",{}).values(): rows.append({"type":"decoration","at":project(Grid.vec(F.SLOTS[int(item.slot)])),"item":item})
	producer_points.clear()
	var offsets: Dictionary = {"chicken":[-6,4],"hive":[-6,0],"cow":[-1,9],"sheep":[3,10]}
	var counts: Dictionary = {}
	for id in f.get("producers",{}):
		var p: Dictionary = f.producers[id]
		var at := project(Grid.vec(offsets[p.kind]))+Vector2(int(counts.get(p.kind,0))*24,0)
		counts[p.kind] = int(counts.get(p.kind,0))+1
		producer_points[id] = at
		rows.append({"type":"producer","at":at,"id":id,"producer":p})
	if f.get("guardian",{}).get("owned",false): rows.append({"type":"guardian","at":project(Vector2(-3,5))})
	if f.get("buildings",{}).get("bouquet_workshop",0)>0: rows.append({"type":"workshop","at":project(Vector2(4,-5))})
	rows.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.at.x<b.at.x if is_equal_approx(a.at.y,b.at.y) else a.at.y<b.at.y)
	for row in rows:
		var at: Vector2 = row.at
		match row.type:
			"plot": plot(int(row.id))
			"environment":
				environment(row.kind,at)
				if row.kind=="house" and f.get("buildings",{}).get("house",1)>=2:
					var planter: Dictionary = art.decor.flowerpot.duplicate(true)
					planter.size = [13,14]; planter.pivot = [6.5,12]
					painted(DECOR,planter,at+Vector2(-27,0)); painted(DECOR,planter,at+Vector2(25,0))
			"decoration":
				var item: Dictionary = row.item
				if item.kind=="well": painted(PAINT,art.environment.well,at)
				else:
					var key: String = "fence_y" if item.kind=="fence" and int(item.get("orientation",0))==1 else item.kind
					if art.decor.has(key): painted(DECOR,art.decor[key],at)
			"guardian": animal("dog",at,"guardian")
			"workshop": painted(DECOR,art.decor.workshop,at)
			"producer":
				var p: Dictionary = row.producer
				animal(p.kind,at,row.id)
				if p.kind=="hive" and p.ready_at>0 and motion and intensity>0:
					for bee in range(2): painted(PAINT,art.environment.bee,at+Vector2(sin(clock*1.5+bee*PI)*20,-25+cos(clock*1.9+bee)*6))
	for id in producer_points:
		var at: Vector2 = producer_points[id]
		var p: Dictionary = f.producers[id]
		var ready: bool = p.ready_at>0 and p.ready_at<=demo.service.clock.now_seconds()
		var text: String = "Pronto!" if ready else "Alimento" if p.ready_at==0 else "Produzindo"
		var badge := StyleBoxFlat.new()
		badge.bg_color = Color(1,0.97,0.86,0.95); badge.set_corner_radius_all(3)
		draw_style_box(badge,Rect2(at+Vector2(-22,-51),Vector2(52,14)))
		draw_string(ThemeDB.fallback_font,at+Vector2(-20,-41),text,HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("244f47"))
	draw_effects()
func producer_hit(point: Vector2) -> String:
	for id in producer_points:
		if Rect2(producer_points[id]-Vector2(25,53),Vector2(50,55)).has_point(point): return id
	return ""

func animal(kind: String, at: Vector2, id: String) -> void:
	if not animations.frames.has(kind): painted(PAINT,art.environment[kind],at); return
	var durations: Array = animations.durations[kind]
	var total: float = float(durations[0])+float(durations[1])+float(durations[2])
	var phase: float = float(abs(id.hash())%999)/999.0*total
	var frame: int = frame_at(durations,fmod(clock+phase,total)) if motion and intensity>0 else 0
	var remaining: float = float(animal_reactions.get(id,0))
	var angle: float = sin((0.35-remaining)*20)*remaining*0.08*intensity if motion and remaining>0 else 0.0
	painted(ANIMALS,animations.frames[kind][frame],at,Color.WHITE,angle)

func _ready() -> void: update_background()
func update_background() -> void:
	if background==null or not is_inside_tree(): return
	var viewport_size := get_viewport_rect().size
	var world_size := viewport_size/scale
	var cover: float = maxf(world_size.x/MEADOW.get_width(),world_size.y/MEADOW.get_height())
	background.scale = Vector2.ONE*cover
	background.position = to_local(viewport_size/2)
func _process(delta: float) -> void:
	super._process(delta)
	for id in animal_reactions: animal_reactions[id] = maxf(0,float(animal_reactions[id])-delta)
	update_background()
	if background!=null:
		background.material.set_shader_parameter("phase",clock)
		background.material.set_shader_parameter("strength",intensity if motion else 0.0)

func producer_feedback(id: String) -> void:
	animal_reactions[id] = 0.35
	if not motion or intensity<=0 or not producer_points.has(id): return
	for i in range(int(8*intensity)):
		if particles.size()>=int(config.max_particles): particles.pop_front()
		particles.append({"at":producer_points[id]-Vector2(0,14),"velocity":Vector2(cos(i*2.4)*14,-16-absf(sin(i*2.4))*15),"age":0.0,"life":0.45,"water":false,"color":Color("efc56b")})
