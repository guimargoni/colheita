extends Control
## Integrated client; domain authority is supplied by the local or remote adapter.

const Service = preload("res://scripts/services/integrated/farm_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const Presenter = preload("res://scripts/ui/cultures/culture_presenter.gd")
const ToolsPanel = preload("res://scripts/ui/care/care_tools_panel.gd")
const Tooltip = preload("res://scripts/ui/care/care_tooltip.gd")
var startup_error: bool = false
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
const View = preload("res://scripts/visual/integrated/farm_view.gd")
const Kit = preload("res://scripts/ui/integrated/game_kit.gd")
const Audio = preload("res://scripts/ui/integrated/audio.gd")
const EconomyUI = preload("res://scripts/ui/integrated/farm_ui.gd")
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
var zoom: float = 3
var camera := Vector2(0,-30)
var pinch_accumulator: float = 1
var accent: TextureRect
var accent_age: float = 1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fast = OS.is_debug_build() and "--integrated-fast" in OS.get_cmdline_user_args()
	service = injected_service
	var player_profile: String = ""
	var server_port: int = 16661
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--player="): player_profile = arg.trim_prefix("--player=")
		if arg.begins_with("--server-port="): server_port = arg.trim_prefix("--server-port=").to_int()
	if service==null and not player_profile.is_empty():
		service = preload("res://scripts/services/integrated/remote_farm.gd").new(player_profile,server_port)
	if service==null:
		var save_path: String = "user://colheita_integrated_fast_v1.json" if fast else "user://colheita_integrated_local_v1.json"
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--integrated-save="):
				save_path = argument.trim_prefix("--integrated-save=")
		service = Service.new(Clock.new(Callable(),60.0 if fast else 1.0,"integrated.fast60.v1" if fast else "integrated.real.v1"),Store.new(save_path))
		var fixture: Dictionary = service.fixture()
		service.load_farm(fixture)
	if service.state.is_empty():
		startup_error = true
		kit.root = self
		kit.label("Não foi possível conectar à fazenda.\nAbra JOGAR_COLHEITAFELIZ.cmd para iniciar o servidor local.\n"+service.error,Rect2(60,80,1100,250),30)
		kit.button("Tentar novamente",Rect2(60,350,400,100),func() -> void: get_tree().reload_current_scene())
		return
	get_window().title = "Colheita · "+str(service.player.name) if service.has_method("social") else "Colheita · Fazenda Viva"
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
	buffer.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
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
	load_preferences()
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
	if startup_error: return
	if service!=null and service.has_method("poll"): service.poll()
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
			status.text = "Reconectando ao servidor local…" if service.has_method("social") else "Não foi possível abrir o save. Reinicie pelo launcher."
	economy_ui.tick(delta)
	economy_ui.fit_open_panel()
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
	if area.size.y<=0: return
	buffer.size = Vector2i(area.size)
	container.size = buffer.size
	container.scale = Vector2.ONE
	container.position = area.position
	world.scale = Vector2.ONE*zoom
	world.position = Vector2(buffer.size)/2-camera*zoom

func frame_camera() -> void:
	var bounds: Array = world.definition.focus_bounds
	zoom = clampf(minf(area.size.x/bounds[2],area.size.y/bounds[3])*0.94,1.5,6.0)
	camera = Vector2(bounds[0]+bounds[2]/2.0,bounds[1]+bounds[3]/2.0)
	update_camera()

func map_point(screen: Vector2) -> Vector2:
	return (screen-container.position-world.position)/zoom

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
	zoom = clampf(zoom+step*0.25,1.5,6.0)
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
	if (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
		if area.has_point(event.position):
			var producer: String = world.producer_hit(map_point(event.position))
			if not producer.is_empty():
				var p: Dictionary = service.state.features.producers[producer]
				feature_action("producer_feed" if p.ready_at==0 else "producer_collect",{"id":producer,"cycle":int(p.cycle)})
				get_viewport().set_input_as_handled()
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
	if startup_error: return
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
	var body: VBoxContainer = economy_ui.shell("Cuidar da plantação")
	var row := HBoxContainer.new(); body.add_child(row)
	kit.illustration(row,kit.item_icon("Cuidados"),96)
	economy_ui.button(row,"Regar",select_care.bind("water"))
	for entry in [["Remover ervas","remove_weeds"],["Remover pragas","remove_pests"]]:
		economy_ui.button(body,entry[0],select_care.bind(entry[1]))
	for id in service.items:
		var item: Dictionary = service.items[id]
		var count: int = int(service.state.inventory.fertilizers.get(id,0))
		economy_ui.button(body,item.name+" · "+str(count)+(" · 1 aplicação" if item.rare else ""),select_care.bind(id),id=="fertilizer.social" or count<1)

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
	var anchor: Vector2 = (container.position+world.position+(world.plot_center(id)-Vector2(0,28))*zoom)/ui_scale
	context_card.show_near(anchor,Rect2(area.position/ui_scale,area.size/ui_scale),demo.context(id),portrait)

var presentation: String = "B"
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
	kit.appearance = world.appearance
	kit.accent = world.appearance.palette("accent")
	kit.paper = world.appearance.palette("paper")
	var header := Panel.new()
	header.position = Vector2(24,20); header.size = Vector2(680 if portrait else 560,100)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_stylebox_override("panel",kit.surface(kit.accent))
	hud.add_child(header)
	economy_ui.build_header()
	seed_label = kit.label(demo.tool_summary(),Rect2(40,128,740,34),22)
	seed_label.visible = false
	var side: float = 104 if portrait else 88
	var x: float = logical.x-side-24
	for entry in [["Loja",economy_ui.open_shop],["Fazenda",open_farm_hub],["Amigos",open_social],["Ajustes",open_studio]]:
		kit.dock(entry[0],Rect2(x,24 if portrait else 20,side,100 if portrait else 88),entry[1])
		x -= side+12
	# In portrait secondary actions sit on a compact right rail, freeing the farm.
	if portrait:
		var n: int = 0
		for child in hud.get_children():
			if child is Button:
				child.position = Vector2(logical.x-128,144+n*116); n += 1
	var y: float = logical.y-128 if portrait else logical.y-112
	var width: float = 140 if portrait else 110
	x = (logical.x-4*(width+14))/2
	for entry in [["Semear","seed"],["Cuidados","care_menu"],["Câmera","camera"]]:
		kit.dock(entry[0],Rect2(x,y,width,108 if portrait else 96),choose.bind(entry[1]),demo.tool==entry[1])
		x += width+14
	kit.dock("Inventário",Rect2(x,y,width,108 if portrait else 96),open_inventory)
	status = kit.label("",Rect2(40,logical.y-178 if portrait else logical.y-152,logical.x-80,40),22)
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	metrics_label = kit.label("",Rect2(40,160,800,32),18,Color("3f6054")); metrics_label.visible = show_metrics
	var top: float = 130
	var footer: float = 144 if portrait else 126
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
	economy_ui.label(body,"Ajuste a apresentação ao seu conforto. Este jogo usa save próprio.")
	economy_ui.button(body,"Movimento: "+("normal" if world.motion else "reduzido"),func() -> void: world.motion = not world.motion; save_preferences(); layout(); open_studio())
	economy_ui.button(body,"Métricas: "+("visíveis" if show_metrics else "ocultas"),func() -> void: show_metrics = not show_metrics; layout(); open_studio())
	economy_ui.label(body,"Intensidade dos efeitos")
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = world.intensity
	slider.custom_minimum_size = Vector2(0,110 if portrait else 60)
	body.add_child(slider)
	slider.value_changed.connect(func(value: float) -> void: world.intensity = value; kit.intensity = value; save_preferences())
	economy_ui.label(body,"Volume dos efeitos")
	var volume := HSlider.new()
	volume.min_value = 0; volume.max_value = 1; volume.step = 0.05; volume.value = audio.gain
	volume.custom_minimum_size = Vector2(0,110 if portrait else 60)
	body.add_child(volume)
	volume.value_changed.connect(func(value: float) -> void: audio.gain = value; save_preferences())
	economy_ui.button(body,"Histórico econômico",economy_ui.open_history)
	economy_ui.button(body,"Créditos",open_credits)
	economy_ui.label(body,"SFX licenciados CC0 de Kenney · mix em revisão. Música e ambiência finais pendentes. Servidor local não equivale a publicação online.")

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

const FeaturesPanel = preload("res://scripts/ui/integrated/features_panel.gd")
var features_panel: RefCounted
func open_farm_hub() -> void:
	features_panel = FeaturesPanel.new(self)
	features_panel.open()

func feature_action(type: String, args: Dictionary = {}) -> Dictionary:
	args.type = type
	args.request_id = Crypto.new().generate_random_bytes(16).hex_encode()
	var result: Dictionary = service.execute(args)
	if result.ok:
		demo.refresh()
		if type in ["producer_feed","producer_collect"]: world.producer_feedback(str(args.get("id","")),"feed" if type=="producer_feed" else "collect")
		status.text = "Ação salva"
		economy_ui.note = "Ação salva"
		economy_ui.burst("+%d XP"%int(result.xp) if result.get("xp",0)>0 else "Pronto!")
		audio.play("buy_seeds" if type.begins_with("buy") else "harvest" if type=="producer_collect" else "button")
	else:
		economy_ui.note = preload("res://scripts/ui/integrated/messages.gd").error(str(result.get("error","unknown")))
		status.text = economy_ui.note
	return result

func open_social() -> void:
	social_panel = preload("res://scripts/ui/integrated/social_panel.gd").new(self)
	social_panel.open()

var social_panel: RefCounted
func _exit_tree() -> void:
	if service!=null and service.has_method("shutdown"): service.shutdown()

func load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load("user://integrated_preferences.cfg")!=OK: return
	world.appearance.set_theme(str(config.get_value("appearance","theme","standard")))
	var saved_skins = config.get_value("appearance","skins",{})
	if saved_skins is Dictionary:
		for entity in saved_skins: world.appearance.set_skin(entity,str(saved_skins[entity]))
	var value = config.get_value("visual","intensity",0.65)
	if (value is int or value is float) and is_finite(float(value)): world.intensity = clampf(float(value),0,1)
	var reduced = config.get_value("visual","reduced",false)
	if reduced is bool: world.motion = not reduced
	value = config.get_value("audio","gain",0.55)
	if (value is int or value is float) and is_finite(float(value)): audio.gain = clampf(float(value),0,1)
func save_preferences() -> void:
	var config := ConfigFile.new()
	config.set_value("appearance","theme",world.appearance.theme)
	config.set_value("appearance","skins",world.appearance.skins)
	config.set_value("visual","intensity",world.intensity)
	config.set_value("visual","reduced",not world.motion)
	config.set_value("audio","gain",audio.gain)
	config.save("user://integrated_preferences.cfg")

func open_credits() -> void:
	var body: VBoxContainer = economy_ui.shell("Autoria e créditos")
	economy_ui.label(body,"Arte 2D original produzida com assistência de IA para este projeto. Sprites e animações continuam em revisão artística.")
	economy_ui.label(body,"Efeitos sonoros: Kenney · Interface Sounds e Impact Sounds · licença CC0 1.0. Obrigado, Kenney!")
	economy_ui.label(body,"Música e ambiência finais ainda não produzidas. Codinome Colheita; identidade comercial sujeita a revisão.")

func open_appearance() -> void:
	var body: VBoxContainer = economy_ui.shell("Ateliê de aparências")
	for id in world.appearance.pack.themes:
		economy_ui.button(body,world.appearance.pack.themes[id].name+(" · ativo" if world.appearance.theme==id else ""),change_theme.bind(id))
	economy_ui.label(body,"Sua casa · cosmético local, sem custo ou efeito na produção")
	var row := HBoxContainer.new(); body.add_child(row)
	kit.illustration(row,world.appearance.preview("environment.house","building.house"),160)
	economy_ui.button(body,"Telhado terracota",change_house_skin.bind(""))
	economy_ui.button(body,"Telhado azul",change_house_skin.bind("house.sky"))
	economy_ui.label(body,"Halloween é visual. Não altera calendário, recompensas, compras ou visitas.")
func change_theme(id: String) -> void:
	cancel_input(); world.set_theme(id); save_preferences(); layout(); open_appearance()
func change_house_skin(id: String) -> void:
	cancel_input(); world.set_skin("building.house",id); save_preferences(); layout(); open_appearance()
