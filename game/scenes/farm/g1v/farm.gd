extends Control
## G1.V isolated presentation experiment; unchanged G1.5 domain and service.

const Service = preload("res://scripts/services/cultures/local_culture_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const Presenter = preload("res://scripts/ui/cultures/culture_presenter.gd")
const ToolsPanel = preload("res://scripts/ui/care/care_tools_panel.gd")
const Tooltip = preload("res://scripts/ui/care/care_tooltip.gd")
var context_card: PanelContainer
var context_id: int = -1
var context_age: float = 0
var injected_service: RefCounted
var service: RefCounted
var fast: bool = false
var seed_label: Label
var refresh_age: float = 0
var stroke_intent: String = ""
const Gesture = preload("res://scripts/prototype/garden_gesture.gd")
const View = preload("res://scripts/visual/g1v/living_view.gd")
const Kit = preload("res://scripts/ui/g1v/living_kit.gd")
const Audio = preload("res://scripts/ui/land/land_audio.gd")
const EconomyUI = preload("res://scripts/ui/g1v/living_economy_ui.gd")
const LandUI = preload("res://scripts/ui/land/land_ui.gd")
var land_ui: RefCounted
var economy_ui: RefCounted
var audio: Node
var demo: RefCounted
var gesture = Gesture.new()
var world: Node2D
var buffer: SubViewport
var container: SubViewportContainer
var hud: Control
var kit = Kit.new()
var status: Label
var panel: PanelContainer
var area: Rect2
var ui_scale: float = 1
var logical := Vector2(1920,1080)
var portrait: bool = false
var zoom: int = 3
var camera := Vector2(0,-30)
var pinch_accumulator: float = 1
var accent: TextureRect
var accent_age: float = 1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fast = OS.is_debug_build() and "--g1v-fast" in OS.get_cmdline_user_args()
	service = injected_service
	if service==null:
		var save_path: String = "user://g1v_fast.json" if fast else "user://g1v_local.json"
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--g1v-save="):
				save_path = argument.trim_prefix("--g1v-save=")
		service = Service.new(Clock.new(Callable(),60.0 if fast else 1.0,"local.cultures.fast60.v5" if fast else "local.cultures.real.v5"),Store.new(save_path))
		var fixture: Dictionary = service.fixture()
		service.load_farm(fixture)
	if injected_service==null and service.error.is_empty():
		preload("res://scripts/visual/g1v/demo_setup.gd").new().seed(service)
	fast = service.clock.rate>1
	demo = Presenter.new(service)
	economy_ui = EconomyUI.new(self)
	economy_ui.note = tr("Toque em um terreno com + para expandir")
	land_ui = LandUI.new(self)
	container = SubViewportContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/visual/g1v/presentation.gdshader")
	container.material = material
	buffer = SubViewport.new()
	buffer.disable_3d = true
	buffer.gui_disable_input = true
	buffer.transparent_bg = true
	buffer.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	buffer.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(buffer)
	world = View.new()
	world.demo = demo
	world.definition = world.definition.duplicate(true)
	world.configure()
	world.definition.plot_positions = demo.plots.map(func(plot: Dictionary) -> Array: return plot.grid)
	buffer.add_child(world)
	hud = Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hud)
	kit.root = hud
	audio = Audio.new()
	add_child(audio)
	audio.set_ambience(true)
	gesture.picker = hit_at
	gesture.action_requested.connect(act)
	gesture.inspection_requested.connect(inspect)
	gesture.pan_requested.connect(pan_camera)
	gesture.zoom_requested.connect(pinch)
	demo.acted.connect(feedback)
	get_viewport().size_changed.connect(resize)
	get_window().focus_exited.connect(func() -> void: cancel_input(); close_studio())
	layout()
	frame_camera()
	kit.intensity = world.intensity

func _process(delta: float) -> void:
	sample_metrics(delta)
	context_age = maxf(0,context_age-delta)
	update_context()
	refresh_age += delta
	if refresh_age>=0.2:
		refresh_age = 0
		demo.refresh()
		seed_label.text = demo.tool_summary()
		if world.hover_id>=0:
			status.text = demo.describe(world.hover_id)
		if not service.error.is_empty():
			status.text = tr("Save indisponível · Menu para reabrir")+": "+service.error
	economy_ui.tick(delta)
	gesture.tick(delta)
	if is_instance_valid(accent):
		accent_age += delta
		accent.modulate.a = maxf(0,1-accent_age/0.18)
		if accent_age>=0.18:
			accent.queue_free()
			accent = null

func cancel_input() -> void:
	gesture.cancel()
	pinch_accumulator = 1

func resize() -> void:
	land_ui.cancel_confirmation()
	cancel_input()
	layout()
	frame_camera()

func update_camera() -> void:
	if area.size.y<=0:
		return
	buffer.size = Vector2i(floor(area.size.x/zoom),floor(area.size.y/zoom))
	container.size = buffer.size
	container.scale = Vector2.ONE*zoom
	container.position = (area.position+(area.size-Vector2(buffer.size)*zoom)/2).floor()
	world.position = (Vector2(buffer.size)/2-camera).round()

func frame_camera() -> void:
	var bounds: Array = world.definition.focus_bounds
	zoom = clampi(int(floor(minf(area.size.x/bounds[2],area.size.y/bounds[3]))),2,6)
	camera = Vector2(bounds[0]+bounds[2]/2.0,bounds[1]+bounds[3]/2.0)
	update_camera()

func map_point(screen: Vector2) -> Vector2:
	return (screen-container.position)/zoom-world.position

func hit_at(screen: Vector2) -> int:
	if panel!=null or not area.has_point(screen):
		return -1
	var cell: Vector2 = View.Grid.unproject(map_point(screen))
	for id in range(demo.plots.size()):
		var center := Vector2(demo.plots[id].grid[0],demo.plots[id].grid[1])
		# Half-open 2x2 ground footprint: no overlapping hitboxes in dense fields.
		if cell.x>=center.x-1 and cell.x<center.x+1 and cell.y>=center.y-1 and cell.y<center.y+1:
			return id
	return -1

func act(id: int) -> void:
	if id<0 or id>=demo.plots.size():
		return
	demo.refresh()
	if gesture.visited.size()<=1:
		stroke_intent = demo.intent_for(id)
	if demo.plots[id].state=="locked":
		if gesture.mode=="paint" or gesture.visited.size()>1:
			if gesture.visited.size()<=1:
				stroke_intent = "locked_skip"
			return
		land_ui.open_plot(demo.plot_ids[id])
		return
	if stroke_intent=="locked_skip":
		return
	world.remember(id)
	var xp_before: int = int(service.state.economy.xp)
	if demo.act(id,stroke_intent).is_empty():
		status.text = demo.error_text() if not demo.last_error.is_empty() else demo.describe(id)
	else:
		var xp_delta: int = int(service.state.economy.xp)-xp_before
		if xp_delta>0: world.reward(id,"+%d XP"%xp_delta)

func feedback(id: int, action: String) -> void:
	context_id = id
	context_age = 5
	world.feedback(id,action)
	audio.play(action)
	seed_label.text = demo.tool_summary()
	economy_ui.on_harvest(action)
	status.text = tr({"harvest":"Colheita salva no inventário","plant":"Plantado e salvo","water":"Regado · hidratação e benefício registrados","remove_weeds":"Ervas removidas · atraso recuperado","remove_pests":"Pragas removidas · atraso recuperado","fertilize":"Fertilizante aplicado · tempo e estoque salvos"}[action])

func inspect(id: int) -> void:
	if id>=0 and id<demo.plots.size():
		status.text = demo.describe(id).replace("\n"," · ")
		world.hover_id = id
		context_id = id
		context_age = 6

func choose(tool: String) -> void:
	if tool=="care_menu":
		open_care_tools()
		return
	audio.play("button")
	cancel_input()
	if tool=="seed" and demo.tool=="seed":
		for offset in range(1,service.catalog.ids.size()+1):
			var index: int = (demo.selected_seed+offset)%service.catalog.ids.size()
			if service.catalog.ids[index] in service.state.get("economy",{}).get("unlocks",[]):
				demo.selected_seed = index
				break
	demo.tool = tool
	demo.rare_armed = false
	gesture.camera_tool = tool=="camera"
	layout()
	show_ui_accent(tool)
	status.text = "Semente: "+tr(service.catalog.entries[demo.selected_id()].name) if tool=="seed" else "Câmera livre · arraste para explorar" if tool=="camera" else ""

func show_ui_accent(_tool: String) -> void:
	pass

func pan_camera(delta: Vector2) -> void:
	camera -= delta/zoom
	camera = camera.clamp(Vector2(world.definition.camera_bounds[0],world.definition.camera_bounds[1]),Vector2(world.definition.camera_bounds[2],world.definition.camera_bounds[3]))
	update_camera()

func change_zoom(step: int, anchor: Vector2) -> void:
	var fixed := map_point(anchor)
	zoom = clampi(zoom+step,3 if portrait else 2,6)
	update_camera()
	camera += fixed-map_point(anchor)
	update_camera()

func pinch(factor: float, anchor: Vector2) -> void:
	pinch_accumulator *= factor
	if pinch_accumulator>1.15 or pinch_accumulator<0.85:
		change_zoom(1 if pinch_accumulator>1 else -1,anchor)
		pinch_accumulator = 1

func toggle_motion() -> void:
	world.motion = not world.motion

func immediate_close() -> void:
	land_ui.cancel_confirmation()
	closing = false
	if panel!=null:
		var shade: Control = panel.get_meta("shade",null)
		if is_instance_valid(shade): shade.queue_free()
		hud.remove_child(panel)
		panel.queue_free()
		panel = null

func _input(event: InputEvent) -> void:
	if gesture.mode=="idle":
		return
	if event is InputEventMouseButton and not event.pressed and event.device!=-1:
		gesture.release(event.position,0,not area.has_point(event.position))
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and event.device!=-1:
		gesture.move(event.position,0)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		gesture.move(event.position,event.index)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		if event.pressed and area.has_point(event.position):
			gesture.press(event.position,event.index)
		elif not event.pressed:
			gesture.release(event.position,event.index,event.canceled or not area.has_point(event.position))
		else:
			cancel_input()
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if panel!=null:
		return
	if event is InputEventMouseButton and area.has_point(event.position) and event.device!=-1:
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			change_zoom(1 if event.button_index==MOUSE_BUTTON_WHEEL_UP else -1,event.position)
		elif event.pressed:
			gesture.press(event.position,0,event.button_index!=MOUSE_BUTTON_LEFT or Input.is_key_pressed(KEY_SPACE))
	elif event is InputEventScreenTouch and event.pressed and area.has_point(event.position):
		gesture.press(event.position,event.index)
	elif event is InputEventMouseMotion:
		world.hover_id = hit_at(event.position)
		if world.hover_id>=0:
			status.text = demo.describe(world.hover_id)

func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE: close_studio(); cancel_input()
			KEY_HOME: frame_camera()
			KEY_1: choose("seed")
			KEY_2: open_care_tools()
			KEY_3: choose("camera")

func _draw() -> void:
	draw_rect(get_viewport_rect(),Color("a4bd79"))

func open_inventory() -> void:
	economy_ui.open_inventory()

func select_seed(index: int) -> void:
	demo.selected_seed = index
	demo.tool = "seed"
	gesture.camera_tool = false
	close_studio()
	layout()
	status.text = demo.tool_summary()

func reload_save() -> void:
	if service.state.is_empty() or not service.error.is_empty():
		var fixture: Dictionary = service.fixture()
		service.load_farm(fixture)
	economy_ui.last_level = int(service.state.get("economy",{}).get("level",1))
	economy_ui.shown_coins = -1
	economy_ui.shown_xp = -1
	demo.refresh()
	close_studio()
	world.definition.plot_positions = demo.plots.map(func(plot: Dictionary) -> Array: return plot.grid)
	layout()
	status.text = tr("Save reaberto") if service.error.is_empty() else tr("Falha no save")+": "+service.error

func open_care_tools() -> void:
	cancel_input()
	close_studio()
	panel = ToolsPanel.create(kit,logical,service,select_care,close_studio)
	panel.add_theme_stylebox_override("panel",kit.surface(Kit.PAPER))

func select_care(tool: String) -> void:
	cancel_input()
	demo.rare_armed = false
	if service.items.has(tool):
		demo.selected_fertilizer = tool
		demo.tool = "fertilize"
		demo.rare_armed = bool(service.items[tool].rare)
	else:
		demo.tool = tool
	gesture.camera_tool = false
	close_studio()
	layout()
	status.text = demo.tool_summary()+" · "+tr("toque ou arraste") if not demo.rare_armed else tr("Super armado para 1 aplicação · arrasto protegido")

func update_context() -> void:
	if context_card==null:
		return
	context_card.visible = false
	if panel!=null:
		return
	var id: int = world.hover_id if world.hover_id>=0 else context_id if context_age>0 else -1
	if id<0 or id>=demo.plots.size():
		return
	var anchor: Vector2 = (container.position+(world.position+world.plot_center(id)-Vector2(0,28))*zoom)/ui_scale
	context_card.show_near(anchor,Rect2(area.position/ui_scale,area.size/ui_scale),demo.context(id),portrait)

var presentation: String = "A"
var closing: bool = false
var frame_samples: Array[float] = []
var metrics_age: float = 0
var metrics_label: Label
var show_metrics: bool = false

func layout() -> void:
	land_ui.cancel_confirmation()
	context_card = null
	for child in hud.get_children():
		hud.remove_child(child)
		child.queue_free()
	panel = null
	closing = false
	var viewport_size := get_viewport_rect().size
	portrait = viewport_size.y>viewport_size.x
	ui_scale = viewport_size.x/(1080.0 if portrait else 1920.0)
	logical = viewport_size/ui_scale
	hud.scale = Vector2.ONE*ui_scale
	kit.mobile = portrait
	kit.hybrid = presentation=="B"
	kit.reduced = not world.motion
	kit.intensity = world.intensity
	world.hybrid = kit.hybrid
	container.material.set_shader_parameter("hybrid",kit.hybrid)
	var header := Panel.new()
	header.position = Vector2(24,24)
	header.size = Vector2(1032 if portrait else 660,136 if portrait else 112)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_stylebox_override("panel",kit.surface(Color("244f47")))
	hud.add_child(header)
	economy_ui.build_header()
	seed_label = kit.label(demo.tool_summary(),Rect2(44,166 if portrait else 148,900,42),26 if portrait else 23)
	kit.label("FAZENDA VIVA  /  "+("A · pixel modernizado" if presentation=="A" else "B · híbrido suave"),Rect2(44,214 if portrait else 26,990 if portrait else 1000,38),22,Kit.INK)
	if not portrait:
		# Keep the edition title outside the wallet surface.
		hud.get_child(hud.get_child_count()-1).position = Vector2(720,30)
	kit.button("Loja",Rect2(24 if portrait else logical.x-350,logical.y-288 if portrait else 24,220 if portrait else 150,96 if portrait else 72),economy_ui.open_shop)
	kit.button("A / B",Rect2(262 if portrait else logical.x-182,logical.y-288 if portrait else 24,220 if portrait else 150,96 if portrait else 72),switch_presentation)
	kit.button("Ajustes",Rect2(500 if portrait else logical.x-350,logical.y-288 if portrait else 112,250 if portrait else 318,96 if portrait else 64),open_studio)
	kit.button("Foco",Rect2(768 if portrait else logical.x-350,logical.y-288 if portrait else 192,288 if portrait else 150,96 if portrait else 64),frame_camera)
	var y: float = logical.y-160 if portrait else logical.y-100
	var width: float = 244 if portrait else 210
	var x: float = 24 if portrait else (logical.x-4*(width+18))/2
	for entry in [["Semear","seed"],["Cuidados","care_menu"],["Câmera","camera"]]:
		kit.button(entry[0],Rect2(x,y,width,124 if portrait else 76),choose.bind(entry[1]),demo.tool==entry[1])
		x += width+18
	kit.button("Inventário",Rect2(x,y,width,124 if portrait else 76),open_inventory)
	status = kit.label("Colha com um toque · demonstração isolada",Rect2(44,logical.y-360 if portrait else logical.y-148,990 if portrait else 900,48),24 if portrait else 22)
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	metrics_label = kit.label("",Rect2(44,logical.y-410 if portrait else logical.y-194,990,40),20,Color("3f6054"))
	metrics_label.visible = show_metrics
	var top: float = 230 if portrait else 132
	var footer: float = 250 if portrait else 84
	area = Rect2(Vector2(0,top)*ui_scale,Vector2(logical.x,logical.y-top-footer)*ui_scale)
	context_card = Tooltip.new()
	context_card.add_theme_stylebox_override("panel",kit.surface(Kit.PAPER))
	hud.add_child(context_card)
	gesture.threshold = 12*ui_scale
	update_camera()
	queue_redraw()

func switch_presentation() -> void:
	cancel_input()
	presentation = "B" if presentation=="A" else "A"
	layout()
	status.text = "Mesma fazenda e lógica · apresentação "+presentation

func open_studio() -> void:
	cancel_input()
	immediate_close()
	var body: VBoxContainer = economy_ui.shell("Seu ritmo, sua fazenda")
	economy_ui.label(body,"Compare A e B sem alterar seu cultivo. Este experimento tem save independente.")
	economy_ui.button(body,"Apresentação "+presentation+" · alternar",func() -> void: switch_presentation(); open_studio())
	economy_ui.button(body,"Movimento: "+("normal" if world.motion else "reduzido"),func() -> void: world.motion = not world.motion; layout(); open_studio())
	economy_ui.button(body,"Métricas: "+("visíveis" if show_metrics else "ocultas"),func() -> void: show_metrics = not show_metrics; layout(); open_studio())
	economy_ui.label(body,"Intensidade dos efeitos")
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = world.intensity
	slider.custom_minimum_size = Vector2(0,110 if portrait else 60)
	body.add_child(slider)
	slider.value_changed.connect(func(value: float) -> void: world.intensity = value; kit.intensity = value)
	economy_ui.button(body,"Histórico econômico",economy_ui.open_history)
	economy_ui.label(body,"Áudio: pontos de integração preparados; sem masters aprovados. Save e relógio locais não certificam segurança online.")

func close_studio() -> void:
	land_ui.cancel_confirmation()
	if panel==null or closing: return
	var departing := panel
	# Remove input immediately; animation must never leave an invisible modal lock.
	panel = null
	closing = true
	var shade: Control = departing.get_meta("shade",null)
	if is_instance_valid(shade): shade.queue_free()
	if not world.motion or world.intensity<=0:
		departing.queue_free()
		closing = false
		return
	for control in departing.find_children("*","Control",true,false):
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.release_focus()
		if control is BaseButton: control.disabled = true
		if control is LineEdit: control.editable = false
	departing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	departing.set_process_input(false)
	var tween := departing.create_tween().set_parallel(true)
	tween.tween_property(departing,"modulate:a",0.0,0.14)
	tween.tween_property(departing,"position:y",departing.position.y+18,0.14)
	tween.chain().tween_callback(func() -> void: departing.queue_free(); closing = false)

func sample_metrics(delta: float) -> void:
	if delta<=0: return
	frame_samples.append(delta*1000)
	if frame_samples.size()>600: frame_samples.pop_front()
	metrics_age += delta
	if metrics_age>=0.5 and is_instance_valid(metrics_label):
		metrics_age = 0
		var sorted: Array[float] = frame_samples.duplicate()
		sorted.sort()
		var p95: float = sorted[int((sorted.size()-1)*0.95)]
		metrics_label.text = "%.0f FPS · p95 %.1f ms · FX %d/%d"%[Engine.get_frames_per_second(),p95,world.particles.size(),int(world.config.max_particles)]
