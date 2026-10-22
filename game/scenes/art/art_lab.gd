extends Control
## Isolated art lab: inspection and camera only; main G0.5 entry remains intact.

const Model = preload("res://scripts/visual/art_lab_model.gd")
const View = preload("res://scripts/visual/art_lab_view.gd")
var model = Model.new()
var world: Node2D
var viewport: SubViewport
var container: SubViewportContainer
var hud: Control
var info: Label
var zoom: int = 4
var camera := Vector2.ZERO
var area: Rect2
var fixture_id: String = "compact"
var expanded: bool = false
var pointers: Dictionary = {}
var press_at := Vector2.ZERO
var moved: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	container = SubViewportContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	viewport = SubViewport.new()
	viewport.disable_3d = true
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.transparent_bg = false
	container.add_child(viewport)
	world = View.new()
	world.model = model
	viewport.add_child(world)
	hud = Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hud)
	get_viewport().size_changed.connect(layout)
	get_window().focus_exited.connect(func() -> void: pointers.clear())
	select_fixture("compact")
	layout()
	frame_all()

func button(text: String, rect: Rect2, action: Callable) -> void:
	var control := Button.new()
	control.text = text
	control.position = rect.position
	control.size = rect.size
	control.add_theme_font_size_override("font_size",24)
	control.pressed.connect(action)
	hud.add_child(control)

func layout() -> void:
	pointers.clear()
	for child in hud.get_children():
		hud.remove_child(child)
		child.queue_free()
	var size := get_viewport_rect().size
	var mobile := size.y>size.x
	var top := 370.0 if mobile else 150.0
	area = Rect2(16,top,size.x-32,size.y-top-150)
	var title := Label.new()
	title.text = tr("G0.5-R · laboratório técnico · sprites G0.5 provisórios")
	title.position = Vector2(24,8)
	title.add_theme_font_size_override("font_size",26)
	hud.add_child(title)
	var labels := ["Compacta","Densa","Alamedas","Fase visual","Paleta","Guias","Geral","−","+","Pausa"]
	var actions: Array[Callable] = [select_fixture.bind("compact"),select_fixture.bind("dense"),select_fixture.bind("avenues"),toggle_expanded,toggle_palette,toggle_guides,frame_all,change_zoom.bind(-1,Vector2.ZERO),change_zoom.bind(1,Vector2.ZERO),toggle_motion]
	var columns := 5 if mobile else 10
	var width := (size.x-48)/columns
	for i in range(labels.size()):
		button(labels[i],Rect2(24+(i%columns)*width,64+(i/columns)*(144 if mobile else 80),width-6,132 if mobile else 76),actions[i])
	info = Label.new()
	info.position = Vector2(24,size.y-136)
	info.size = Vector2(size.x-48,128)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size",24)
	hud.add_child(info)
	update_camera()
	update_info()

func select_fixture(key: String) -> void:
	fixture_id = key
	world.plots = model.fixture(key,expanded)
	world.selected = -1
	world.queue_redraw()
	if is_instance_valid(info):
		update_info()

func toggle_expanded() -> void:
	expanded = not expanded
	select_fixture(fixture_id)

func toggle_palette() -> void:
	world.palette = not world.palette
	world.queue_redraw()
	update_info()

func toggle_guides() -> void:
	world.guides = not world.guides
	world.queue_redraw()

func toggle_motion() -> void:
	world.motion = not world.motion

func frame_all() -> void:
	var bounds: Rect2 = model.bounds(world.plots)
	zoom = clampi(int(floor(minf(area.size.x/bounds.size.x,area.size.y/bounds.size.y))),1,6)
	camera = bounds.get_center().round()
	update_camera()
	update_info()

func update_camera() -> void:
	if area.size.x<=0 or area.size.y<=0:
		return
	viewport.size = Vector2i(floor(area.size.x/zoom),floor(area.size.y/zoom))
	container.scale = Vector2.ONE*zoom
	container.size = viewport.size
	container.position = (area.position+(area.size-Vector2(viewport.size)*zoom)/2).floor()
	world.position = (Vector2(viewport.size)/2-camera).round()

func change_zoom(step: int, anchor: Vector2) -> void:
	if anchor==Vector2.ZERO:
		anchor = area.get_center()
	var fixed := map_point(anchor)
	zoom = clampi(zoom+step,1,6)
	update_camera()
	camera += fixed-map_point(anchor)
	camera = camera.round()
	update_camera()
	update_info()

func map_point(screen: Vector2) -> Vector2:
	return (screen-container.position)/zoom-world.position

func update_info() -> void:
	if not is_instance_valid(info):
		return
	info.text = tr("Carga de laboratório: %d espaços · zoom inteiro %d× · B bloqueado / V vazio / mudas / maduro.\nInspeção e câmera apenas; sem desbloqueio real. Paleta de teste, não skin final.")%[world.plots.size(),zoom]

func inspect(screen: Vector2) -> void:
	world.selected = model.pick(map_point(screen),world.plots)
	world.queue_redraw()
	if world.selected>=0:
		var plot: Dictionary = world.plots[world.selected]
		info.text = "%s · %s · célula %s\nSem ação agrícola ou compra; estado apenas demonstrativo."%[plot.id,plot.state,plot.cell]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and area.has_point(event.position):
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			change_zoom(1 if event.button_index==MOUSE_BUTTON_WHEEL_UP else -1,event.position)
		elif event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT,MOUSE_BUTTON_MIDDLE]:
			if event.pressed:
				pointers[0] = event.position
				press_at = event.position
				moved = false
			else:
				if not moved:
					inspect(event.position)
				pointers.clear()
	elif event is InputEventMouseMotion and pointers.has(0):
		pan_to(event.position,0)
	elif event is InputEventScreenTouch:
		if event.pressed and area.has_point(event.position):
			pointers[event.index] = event.position
			press_at = event.position
			moved = pointers.size()>1
		else:
			if pointers.size()==1 and pointers.has(event.index) and not moved and not event.canceled:
				inspect(event.position)
			pointers.erase(event.index)
	elif event is InputEventScreenDrag and pointers.has(event.index):
		if pointers.size()==2:
			var keys := pointers.keys()
			var other: Vector2 = pointers[keys[0] if keys[1]==event.index else keys[1]]
			var old_distance: float = pointers[event.index].distance_to(other)
			if absf(event.position.distance_to(other)-old_distance)>24:
				change_zoom(1 if event.position.distance_to(other)>old_distance else -1,(event.position+other)/2)
				pointers[event.index] = event.position
			moved = true
		else:
			pan_to(event.position,event.index)
	elif event is InputEventKey and event.pressed:
		if event.keycode==KEY_HOME:
			frame_all()

func pan_to(point: Vector2, index: int) -> void:
	if press_at.distance_to(point)>12:
		moved = true
	var delta: Vector2 = point-pointers[index]
	camera -= delta/zoom
	var limits: Rect2 = model.bounds(world.plots).grow(160)
	camera = camera.clamp(limits.position,limits.end)
	pointers[index] = point
	update_camera()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and not area.has_point(event.position):
		pointers.clear()
	elif event is InputEventScreenTouch and event.canceled:
		pointers.clear()
