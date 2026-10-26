extends "res://scripts/visual/g15_view.gd"
## Presentation-only motion. No callbacks mutate domain, clocks, inventories or rewards.
var intensity: float = 0.65
var hybrid: bool = false
var active_plot: int = -1
var springs: Dictionary = {}
var ghosts: Array[Dictionary] = []
var pending_ghost: Dictionary = {}
var particles: Array[Dictionary] = []
var reward_labels: Array[Dictionary] = []
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/visual/g1v/feel.json"))

func configure() -> void:
	super.configure()
	intensity = float(config.default_intensity)
	# Restore only the pre-existing decorative chicken; no animal domain or production.
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/g06/reference.json"))
	for entity in original.entities:
		if entity.kind=="chicken": definition.entities.append(entity)

func _process(delta: float) -> void:
	if motion: clock += delta*intensity
	queue_redraw()
	for id in springs: springs[id] = maxf(0,springs[id]-delta)
	for g in ghosts: g.age += delta
	ghosts = ghosts.filter(func(g: Dictionary) -> bool: return g.age<0.38)
	for p in particles:
		p.age += delta
	particles = particles.filter(func(p: Dictionary) -> bool: return p.age<p.life)
	for r in reward_labels: r.age += delta
	reward_labels = reward_labels.filter(func(r: Dictionary) -> bool: return r.age<0.9)

func remember(id: int) -> void:
	pending_ghost = {"id":id,"state":demo.plots[id].duplicate(true)}

func feedback(id: int, action: String) -> void:
	springs[id] = 0.4
	if action=="harvest" and not pending_ghost.is_empty() and pending_ghost.id==id:
		if ghosts.size()>=12: ghosts.pop_front()
		ghosts.append({"id":id,"state":pending_ghost.state,"age":0.0})
	pending_ghost = {}
	if not motion or intensity<=0: return
	var count: int = int(config.particles_per_action*intensity)
	for i in range(count):
		if particles.size()>=int(config.max_particles): particles.pop_front()
		var angle: float = float(i)*2.399+id
		var water: bool = action=="water"
		particles.append({"at":plot_center(id)+Vector2(0,-12),"velocity":Vector2(cos(angle)*18,-18-absf(sin(angle))*21),"age":0.0,"life":0.35+float(i%4)*0.08,"water":water,"color":Color("75cce0") if water else Color("e8d785") if action=="fertilize" else Color("e7ba53") if action=="harvest" else Color("9ab966")})

func reward(id: int, text: String) -> void:
	if reward_labels.size()>=8: reward_labels.pop_front()
	reward_labels.append({"id":id,"text":text,"age":0.0})

func sprite(texture: Texture2D, item: Dictionary, at: Vector2, tint: Color = Color.WHITE) -> void:
	var plant: bool = active_plot>=0 and texture in [CROPS,NEW_CROPS] and float(item.size[0])<48
	var wind: float = 0
	var bounce: float = 0
	if plant and motion and intensity>0:
		wind = sin(clock*1.7+active_plot*1.83+at.x*0.03)*0.023*intensity
		var life: float = springs.get(active_plot,0.0)
		bounce = sin((0.4-life)*22)*life*0.16*intensity if life>0 else 0.0
		if demo.plots[active_plot].state=="mature":
			tint = tint.lerp(Color(1.10,1.08,1.0),maxf(0,sin(clock*1.25+active_plot*2.0))*0.24*intensity)
	if plant:
		draw_set_transform(at,wind,Vector2(1+bounce,1-bounce))
		super.sprite(texture,item,Vector2.ZERO,tint)
		draw_set_transform(Vector2.ZERO)
	else:
		super.sprite(texture,item,at,tint)

func environment(key: String, at: Vector2) -> void:
	if motion and intensity>0 and (key in ["tree","pine","bush","flowers"]):
		# Contact/pivot is fixed. Tiny rigid rotation is a prototype, not final foliage rig.
		draw_set_transform(at,sin(clock*0.9+at.x*0.041)*0.008*intensity)
		super.environment(key,Vector2.ZERO)
		draw_set_transform(Vector2.ZERO)
	else:
		super.environment(key,at)

func plot(id: int) -> void:
	active_plot = id
	super.plot(id)
	active_plot = -1

func draw_effects() -> void:
	for g in ghosts:
		if not motion or intensity<=0: continue
		var state: Dictionary = g.state
		var key: String = state.key
		var origin: Vector2 = plot_center(g.id)-Vector2(0,g.age*20*intensity)
		var alpha: float = 1-g.age/0.38
		var texture: Texture2D = NEW_CROPS if expanded.sockets.has(state.crop_id) else CROPS
		var item: Dictionary = expanded.sprites.get(key,{}) if texture==NEW_CROPS else definition.crops.get(key,{})
		if not item.is_empty():
			var sockets: Array = expanded.sockets[state.crop_id] if texture==NEW_CROPS else definition.seed_sockets
			for socket in sockets:
				super.sprite(texture,item,origin+Grid.vec(socket),Color(1,1,1,alpha))
	for p in particles:
		if not motion or intensity<=0: continue
		var color: Color = p.color
		color.a *= 1-p.age/p.life
		var point: Vector2 = particle_position(p)
		if p.water: draw_line(point,point+Vector2(-1,-3),color,1.2,true)
		else: draw_circle(point,0.9,color)
	for r in reward_labels:
		var at: Vector2 = plot_center(r.id)+Vector2(-20,-34-(r.age*12 if motion else 0))
		draw_string(ThemeDB.fallback_font,at+Vector2(1,1),r.text,HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color(0.12,0.24,0.23,1-r.age/0.9))
		draw_string(ThemeDB.fallback_font,at,r.text,HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color(1,0.96,0.78,1-r.age/0.9))
	if motion and intensity>0:
		for i in range(4):
			var phase: float = fmod(clock*0.13+i*0.31,1.0)
			var at := Vector2(-130+i*90+sin(clock*0.5+i)*4,-110+phase*190)
			draw_line(at,at+Vector2(2,1),Color(0.85,0.86,0.5,sin(phase*PI)*0.38*intensity),1)

func particle_position(p: Dictionary) -> Vector2:
	return p.at+p.velocity*p.age+Vector2(0,12*p.age*p.age)
