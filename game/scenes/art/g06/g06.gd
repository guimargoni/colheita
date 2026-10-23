extends Control
## G0.6: composed reference scene, preserving the v2 and earlier entry points.

const Garden = preload("res://scripts/prototype/local_garden.gd")
const Gesture = preload("res://scripts/prototype/garden_gesture.gd")
const View = preload("res://scripts/visual/g06_view.gd")
const Kit = preload("res://scripts/ui/pilot_ui.gd")
const Audio = preload("res://scripts/audio/review_audio.gd")
var audio: Node
var demo = Garden.new()
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
	demo.config = demo.config.duplicate(true)
	demo.config.seeds.resize(2)
	var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/g06/reference.json"))
	demo.config.initial_states = definition.initial_states
	demo.reset()
	for id in range(4):
		demo.plots[id].seed = definition.seed_indices[id]
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
	get_window().focus_exited.connect(cancel_input)
	layout()
	frame_camera()

func _process(delta: float) -> void:
	demo.tick(delta)
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
	cancel_input()
	layout()
	frame_camera()

func layout() -> void:
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
	bar.size = Vector2(800,104 if portrait else 80)
	var header := StyleBoxFlat.new()
	header.bg_color = Kit.INK
	header.border_color = Color("f2c34e")
	header.set_border_width_all(2)
	header.set_corner_radius_all(12)
	bar.add_theme_stylebox_override("panel",header)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(bar)
	kit.icon(Rect2(125,590,330,330),Rect2(44,30,48,48))
	kit.label("2.450",Rect2(110,28,190,52),32,Kit.PAPER)
	kit.label("NV 07 · XP 320 / 500",Rect2(320,32,480,48),28,Kit.PAPER)
	var top := 176.0 if portrait else 108.0
	var footer := 232.0 if portrait else 108.0
	area = Rect2(Vector2(0,top)*ui_scale,Vector2(w,h-top-footer)*ui_scale)
	var width := (w-72)/4 if portrait else 240.0
	var y := h-164 if portrait else h-94
	var x := 24.0 if portrait else (w-4*(width+12))/2
	for entry in [["Semear","seed"],["Regar","water"],["Câmera","camera"]]:
		kit.button(entry[0],Rect2(x,y,width,144 if portrait else 76),choose.bind(entry[1]),demo.tool==entry[1])
		x += width+12
	kit.button("Estúdio",Rect2(x,y,width,144 if portrait else 76),open_studio)
	var strip := Panel.new()
	strip.position = Vector2(24,h-footer+4)
	strip.size = Vector2(w-48 if portrait else 720,48)
	var paper := StyleBoxFlat.new()
	paper.bg_color = Kit.PAPER
	paper.set_corner_radius_all(8)
	strip.add_theme_stylebox_override("panel",paper)
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(strip)
	status = kit.label("Colha com um toque · arraste para cuidar",Rect2(36,h-footer+4,w-72 if portrait else 700,44),25 if portrait else 21)
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if not portrait:
		strip.position = Vector2(856,28)
		status.position = Vector2(868,30)
	kit.button("Menu",Rect2(w-228,16,204,144 if portrait else 80),open_studio)
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
	var point := map_point(screen)
	var nearest := -1
	var distance := INF
	for id in range(4):
		var offset: Vector2 = point-(world.plot_center(id)-Vector2(0,8))
		if absf(offset.x)<=32 and absf(offset.y)<=24 and offset.length_squared()<distance:
			distance = offset.length_squared()
			nearest = id
	return nearest

func act(id: int) -> void:
	if id<0 or id>=4:
		return
	if demo.act(id).is_empty():
		inspect(id)

func feedback(id: int, action: String) -> void:
	world.feedback(id,action)
	audio.play(action)
	status.text = tr({"harvest":"Colhido! Solo pronto para outra semente.","plant":"Plantado! Selecione o regador para cuidar.","water":"Regado! Crescimento de demonstração."}[action])

func inspect(id: int) -> void:
	if id>=0 and id<4:
		status.text = demo.describe(id).replace("\n"," · ")
		world.hover_id = id

func choose(tool: String) -> void:
	audio.play("button")
	cancel_input()
	if tool=="seed" and demo.tool=="seed":
		demo.selected_seed = (demo.selected_seed+1)%2
	demo.tool = tool
	gesture.camera_tool = tool=="camera"
	layout()
	show_ui_accent(tool)
	status.text = "Semente: "+str(demo.config.seeds[demo.selected_seed].name) if tool=="seed" else "Câmera livre · arraste para explorar" if tool=="camera" else "Regador · toque ou arraste nos canteiros com sede"

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
	accent.position = Vector2(x+(width+12)*["seed","water","camera"].find(tool)+width/2-24,logical.y-(192 if portrait else 122))
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(accent)
	accent_age = 0

func pan_camera(delta: Vector2) -> void:
	camera -= delta/zoom
	camera = camera.clamp(Vector2(-180,-180),Vector2(180,160))
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
	var text := kit.label("G0.6 · direção conceitual aprovada.\nSprites/FX em revisão; fonte provisória.\nÁudio final ausente. Moedas/XP fictícios.",Rect2(0,90,820,160),28,Kit.INK,content)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kit.button("Movimento reduzido / normal",Rect2(0,280,820,144),toggle_motion,false,content)
	kit.button("Enquadrar",Rect2(0,442,394,144),frame_camera,false,content)
	var disabled := kit.button("Em breve",Rect2(414,442,406,144),func() -> void: pass,false,content)
	disabled.disabled = true
	kit.button("Voltar à fazenda",Rect2(0,610,820,144),close_studio,true,content)

func toggle_motion() -> void:
	world.motion = not world.motion

func close_studio() -> void:
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

func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE: close_studio(); cancel_input()
			KEY_HOME: frame_camera()
			KEY_1: choose("seed")
			KEY_2: choose("water")
			KEY_3: choose("camera")

func _draw() -> void:
	draw_rect(get_viewport_rect(),Color("a4bd79"))
