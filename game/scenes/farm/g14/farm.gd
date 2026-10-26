extends Control
## G1.4: care UI and contextual timer; preserve the original G1.1 scene and saves.

const Service = preload("res://scripts/services/land/local_land_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const Presenter = preload("res://scripts/ui/land/land_presenter.gd")
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
const View = preload("res://scripts/visual/g14_view.gd")
const Kit = preload("res://scripts/ui/pilot_ui.gd")
const Audio = preload("res://scripts/ui/land/land_audio.gd")
const EconomyUI = preload("res://scripts/ui/economy/economy_ui.gd")
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
	fast = OS.is_debug_build() and "--g14-fast" in OS.get_cmdline_user_args()
	service = injected_service
	if service==null:
		service = Service.new(Clock.new(Callable(),60.0 if fast else 1.0,"local.land.fast60.v4" if fast else "local.land.real.v4"),Store.new("user://g14_fast.json" if fast else "user://g14_local.json"))
		var fixture: Dictionary = service.fixture()
		service.load_farm(fixture)
	fast = service.clock.rate>1
	demo = Presenter.new(service)
	economy_ui = EconomyUI.new(self)
	economy_ui.note = tr("Toque em um terreno com + para expandir")
	land_ui = LandUI.new(self)
	container = SubViewportContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
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

func _process(delta: float) -> void:
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

func layout() -> void:
	land_ui.cancel_confirmation()
	context_card = null
	accent = null
	for child in hud.get_children():
		hud.remove_child(child)
		child.queue_free()
	panel = null
	var size := get_viewport_rect().size
	portrait = size.y>size.x
	ui_scale = size.x/(1080.0 if portrait else 1920.0)
	logical = size/ui_scale
	hud.scale = Vector2.ONE*ui_scale
	kit.mobile = portrait
	var w := logical.x
	var h := logical.y
	var bar := Panel.new()
	bar.position = Vector2(24,16)
	bar.size = Vector2(600 if portrait else 800,112 if portrait else 80)
	var header := StyleBoxFlat.new()
	header.bg_color = Kit.INK
	header.border_color = Color("f2c34e")
	header.set_border_width_all(2)
	header.set_corner_radius_all(12)
	bar.add_theme_stylebox_override("panel",header)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(bar)
	economy_ui.build_header()
	seed_label = kit.label(demo.tool_summary(),Rect2(44,62 if portrait else 56,540 if portrait else 730,38),22 if portrait else 20,Kit.PAPER)
	var top := 212.0 if portrait else 132.0
	var footer := 232.0 if portrait else 108.0
	area = Rect2(Vector2(0,top)*ui_scale,Vector2(w,h-top-footer)*ui_scale)
	var width := (w-72)/4 if portrait else 240.0
	var y := h-164 if portrait else h-94
	var x := 24.0 if portrait else (w-4*(width+12))/2
	for entry in [["Semear","seed"],["Cuidados","care_menu"],["Câmera","camera"]]:
		kit.button(entry[0],Rect2(x,y,width,144 if portrait else 76),choose.bind(entry[1]),demo.tool==entry[1])
		x += width+12
	kit.button("Inventário",Rect2(x,y,width,144 if portrait else 76),open_inventory)
	var strip := Panel.new()
	strip.position = Vector2(24,h-footer+4)
	strip.size = Vector2(w-48 if portrait else 720,48)
	var paper := StyleBoxFlat.new()
	paper.bg_color = Kit.PAPER
	paper.set_corner_radius_all(8)
	strip.add_theme_stylebox_override("panel",paper)
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(strip)
	status = kit.label("TESTE 60× · save separado" if fast else "Passe sobre uma planta ou segure para ver o tempo",Rect2(36,h-footer+4,w-72 if portrait else 700,44),25 if portrait else 21)
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if not portrait:
		strip.position = Vector2(856,80)
		status.position = Vector2(868,82)
	kit.button("Loja",Rect2(w-420,16,180,144 if portrait else 64),economy_ui.open_shop)
	kit.button("Menu",Rect2(w-228,16,204,144 if portrait else 64),open_studio)
	context_card = Tooltip.new()
	hud.add_child(context_card)
	gesture.threshold = 12*ui_scale
	update_camera()

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
	if demo.act(id,stroke_intent).is_empty():
		status.text = demo.error_text() if not demo.last_error.is_empty() else demo.describe(id)

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

func show_ui_accent(tool: String) -> void:
	var source := AtlasTexture.new()
	source.atlas = View.FX
	var r: Array = world.definition.fx.button.rect
	source.region = Rect2(r[0],r[1],r[2],r[3])
	accent = TextureRect.new()
	accent.texture = source
	accent.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	accent.size = Vector2(48,28)
	var width := (logical.x-72)/4 if portrait else 240.0
	var x := 24.0 if portrait else (logical.x-4*(width+12))/2
	accent.position = Vector2(x+(width+12)*["seed","care_menu","camera"].find(tool)+width/2-24,logical.y-(192 if portrait else 122))
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(accent)
	accent_age = 0

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

func open_studio() -> void:
	audio.play("button")
	cancel_input()
	if panel!=null:
		return
	panel = PanelContainer.new()
	panel.position = Vector2((logical.x-948)/2,(logical.y-898)/2)
	panel.size = Vector2(948,898)
	var skin := kit.box(Rect2(1080,64,435,418))
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		skin.set_content_margin(side,64)
	panel.add_theme_stylebox_override("panel",skin)
	hud.add_child(panel)
	var content := Control.new()
	content.custom_minimum_size = Vector2(820,770)
	panel.add_child(content)
	kit.label("Cozy Pixel Art · Fazenda Viva",Rect2(0,0,820,66),36,Kit.INK,content)
	var text := kit.label("G1.4 · agricultura local de desenvolvimento.\nRelógio e save manipuláveis; não é anti-cheat.\n"+service.error if not service.error.is_empty() else "G1.4 · crescimento e inventário persistentes.\nAutoridade local apenas para desenvolvimento.\nEconomia DEV; áudio final pendente.",Rect2(0,90,820,160),28,Kit.INK,content)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kit.button("Histórico econômico DEV",Rect2(0,260,820,112),economy_ui.open_history,false,content)
	kit.button("Movimento reduzido / normal",Rect2(0,384,820,64),toggle_motion,false,content)
	kit.button("Enquadrar",Rect2(0,442,394,144),frame_camera,false,content)
	kit.button("Reabrir save",Rect2(414,442,406,144),reload_save,false,content)
	kit.button("Voltar à fazenda",Rect2(0,610,820,144),close_studio,true,content)

func toggle_motion() -> void:
	world.motion = not world.motion

func close_studio() -> void:
	land_ui.cancel_confirmation()
	if panel!=null:
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
