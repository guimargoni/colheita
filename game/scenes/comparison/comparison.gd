extends Control
## In-engine comparison shell. All HUD values are static art-direction fixtures.

const FarmStudy = preload("res://scripts/visual/farm_study.gd")
const INK := Color("29463c")
const MUTED := Color("6f8171")
const PAPER := Color("faf2d9")
const DARK := Color("254c41")
const GOLD := Color("deb96c")

@export_enum("menu", "A", "B") var initial_direction: String = "menu"
var direction: String = "menu"
var world: FarmStudy
var world_layer: Control
var ui: Control
var frame: Rect2
var zoom_factor: float = 1.0
var pan := Vector2.ZERO
var ui_scale: float = 1.0
var portrait: bool = false
var logical_size := Vector2(1920,1080)
var touches: Dictionary = {}
var pointer_start := Vector2.ZERO
var pointer_last := Vector2.ZERO
var dragging: bool = false
var moved: bool = false
var panel: PanelContainer
var note: Label
var reduced_motion: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	world_layer = Control.new()
	world_layer.clip_contents = true
	world_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world_layer)
	world = FarmStudy.new()
	world_layer.add_child(world)
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	get_viewport().size_changed.connect(_layout)
	set_direction(initial_direction)


func style(color: Color, radius: int = 20, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = color
	result.set_corner_radius_all(radius)
	result.border_color = border
	result.set_border_width_all(1 if border.a > 0 else 0)
	result.content_margin_left = 24
	result.content_margin_right = 24
	result.content_margin_top = 18
	result.content_margin_bottom = 18
	return result


func label_at(text: String, area: Rect2, font_size: int, color: Color = INK, parent: Control = null) -> Label:
	var item := Label.new()
	item.text = tr(text)
	item.position = area.position
	item.size = area.size
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent != null else ui).add_child(item)
	return item


func button_at(text: String, area: Rect2, action: Callable, primary: bool = false, parent: Control = null) -> Button:
	var button := Button.new()
	button.text = tr(text)
	button.position = area.position
	button.size = area.size
	button.add_theme_font_size_override("font_size", 25 if not portrait else 42)
	button.add_theme_color_override("font_color", PAPER if primary else INK)
	button.add_theme_color_override("font_hover_color", PAPER if primary else INK)
	button.add_theme_stylebox_override("normal", style(DARK if primary else PAPER,16,Color("d4d8b7")))
	button.add_theme_stylebox_override("hover", style(Color("3d6550") if primary else Color("fff9e9"),16,GOLD))
	button.add_theme_stylebox_override("pressed", style(Color("547652") if primary else Color("e2d6b1"),16,GOLD))
	button.add_theme_stylebox_override("focus", style(Color(0,0,0,0),16,GOLD))
	button.pressed.connect(action)
	(parent if parent != null else ui).add_child(button)
	return button


func card(area: Rect2, color: Color = PAPER) -> Panel:
	var item := Panel.new()
	item.position = area.position
	item.size = area.size
	item.add_theme_stylebox_override("panel", style(color,22))
	ui.add_child(item)
	return item


func set_direction(value: String) -> void:
	touches.clear()
	dragging = false
	direction = value
	world.isometric = value != "B"
	world.selected_plot = -1
	zoom_factor = 1.0
	pan = Vector2.ZERO
	_layout()


func _layout() -> void:
	if not is_instance_valid(ui):
		return
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	panel = null
	var viewport := get_viewport_rect().size
	portrait = viewport.y > viewport.x
	ui_scale = viewport.x / (1080.0 if portrait else 1920.0)
	logical_size = viewport / ui_scale
	ui.scale = Vector2.ONE * ui_scale
	ui.size = logical_size
	if direction == "menu":
		_build_menu()
	else:
		_build_hud()
	_update_camera()
	queue_redraw()


func _build_menu() -> void:
	world.visible = false
	var width := logical_size.x
	label_at("COLHEITA / ESTÚDIO",Rect2(64,40,width-128,44),26,MUTED)
	label_at("Uma fazenda.\nDuas maneiras de sentir.",Rect2(64,130,width-128,200),64 if portrait else 72)
	label_at("Direção visual em avaliação • G0.3",Rect2(68,346,width-136,50),28,MUTED)
	var y := 460.0 if portrait else 440.0
	var card_width := width-128 if portrait else (width-160)/2
	for i in range(2):
		var x := 64.0 if portrait else 64.0+i*(card_width+32)
		var cy := y+i*470 if portrait else y
		var area := Rect2(x,cy,card_width,420 if portrait else 370)
		card(area,Color("e6e9cf") if i == 0 else Color("e9dfc1"))
		var name := "A  /  ISOMÉTRICA" if i == 0 else "B  /  OBLÍQUA"
		label_at(name,Rect2(x+30,cy+24,card_width-60,48),33)
		label_at("Clássica modernizada" if i == 0 else "Top-down premium",Rect2(x+30,cy+94,card_width-60,55),38)
		label_at("Volumes, profundidade e canteiros em destaque.\n16 canteiros • casa • animais • expansão" if i == 0 else "Leitura direta e maior compatibilidade de arte.\n16 canteiros • casa • animais • expansão",Rect2(x+30,cy+158,card_width-60,90),32 if portrait else 24,MUTED)
		button_at("Explorar proposta " + ("A" if i == 0 else "B"),Rect2(x+30,cy+272,card_width-60,132 if portrait else 68),set_direction.bind("A" if i == 0 else "B"),true)
	label_at("Arraste para explorar  /  Use a roda ou dois dedos para aproximar",Rect2(64,logical_size.y-116,width-128,50),24,MUTED)


func _build_hud() -> void:
	world.visible = true
	var width := logical_size.x
	button_at("‹  Comparar",Rect2(28,24,300 if portrait else 214,132 if portrait else 64),set_direction.bind("menu"))
	label_at("COLHEITA",Rect2(370 if portrait else 270,23,360,55),42 if portrait else 32)
	label_at("ESTUDO VISUAL / " + direction,Rect2(373 if portrait else 273,86 if portrait else 68,430,40),26 if portrait else 18,MUTED)
	if portrait:
		card(Rect2(28,184,1024,152),DARK)
		label_at("●  %s moedas" % world.fixture.preview_coins,Rect2(60,206,550,100),42,PAPER)
		label_at("NÍVEL\n%s" % world.fixture.preview_level,Rect2(730,207,140,105),32,Color("eed79a"))
		label_at("Acolher, cultivar, expandir.",Rect2(36,374,1000,55),42)
		label_at("16 canteiros • uma pequena fazenda viva",Rect2(38,437,1000,42),28,MUTED)
		frame = Rect2(20,535,width-40,logical_size.y-955)
	else:
		card(Rect2(width-818,22,590,82),DARK)
		label_at("●  %s moedas" % world.fixture.preview_coins,Rect2(width-790,33,340,60),27,PAPER)
		label_at("NÍVEL %s" % world.fixture.preview_level,Rect2(width-446,33,190,60),25,Color("eed79a"))
		card(Rect2(28,186,288,340))
		label_at("A" if direction == "A" else "B",Rect2(54,206,230,80),64,Color("75915d"))
		label_at("Isométrica\nmodernizada" if direction == "A" else "Oblíqua\npremium",Rect2(54,294,240,105),31)
		label_at("16 canteiros\nUm refúgio para crescer.",Rect2(54,424,250,78),21,MUTED)
		frame = Rect2(344,150,width-370,logical_size.y-290)
	var bottom := logical_size.y-(194 if portrait else 118)
	var nav_width := 210.0 if not portrait else 300.0
	var nav_start := (width-(nav_width*3+32))/2.0
	for i in range(3):
		var title: String = ["Loja", "Amigos", "Inventário"][i]
		button_at(title,Rect2(nav_start+i*(nav_width+16),bottom,nav_width,132 if portrait else 78),_open_preview.bind(title),i==0)
	button_at("A ↔ B",Rect2(width-190 if portrait else width-177,portrait_size_y(24,194),162 if portrait else 145,132 if portrait else 64),set_direction.bind("B" if direction == "A" else "A"))
	var control_y := bottom-(164 if portrait else 94)
	var target := 132.0 if portrait else 64.0
	button_at("−",Rect2(width-(450 if portrait else 253),control_y,target,target),_zoom.bind(0.85,Vector2.ZERO))
	button_at("+",Rect2(width-(310 if portrait else 179),control_y,target,target),_zoom.bind(1.17,Vector2.ZERO))
	button_at("⌂",Rect2(width-(170 if portrait else 105),control_y,target,target),reset_camera)
	button_at("Pausar" if not reduced_motion else "Animar",Rect2(28,control_y,210 if portrait else 160,target),toggle_motion)
	button_at("Canteiros",Rect2(252 if portrait else 202,control_y,280 if portrait else 180,target),focus_plots)
	var caption := "Arraste para explorar • toque num canteiro para inspecionar"
	note = label_at(caption,Rect2(30,logical_size.y-40,width-60,32),18 if not portrait else 23,MUTED)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("JARDIM DO AMANHÃ",Rect2(frame.position.x+20,frame.position.y-37,600,35),19,MUTED)


func portrait_size_y(landscape: float, mobile: float) -> float:
	return mobile if portrait else landscape


func reset_camera() -> void:
	zoom_factor = 1
	pan = Vector2.ZERO
	_update_camera()


func focus_plots() -> void:
	zoom_factor = 2.15 if portrait else 1.6
	pan = Vector2.ZERO
	_update_camera()
	var center := world.to_global(world.project(Vector2(4.75,5.0)))
	pan += frame.get_center()-center/ui_scale
	_clamp_pan()
	_update_camera()


func toggle_motion() -> void:
	reduced_motion = not reduced_motion
	world.animation_enabled = not reduced_motion
	_layout()


func _update_camera() -> void:
	if direction == "menu":
		return
	var points := world.ground_rect(Vector2(-1.6,-1.6),Vector2(13,11.8))
	var bounds := Rect2(points[0],Vector2.ZERO)
	for p in points:
		bounds = bounds.expand(p)
	bounds.position.y -= 100
	bounds.size.y += 115
	var fit := minf(frame.size.x / bounds.size.x,frame.size.y / bounds.size.y)*0.91
	world_layer.position = frame.position*ui_scale
	world_layer.size = frame.size*ui_scale
	world.scale = Vector2.ONE * fit * zoom_factor * ui_scale
	world.position = (frame.get_center()-frame.position+pan)*ui_scale-bounds.get_center()*world.scale


func _zoom(factor: float, screen_anchor: Vector2) -> void:
	if direction == "menu":
		return
	var before := world.to_local(screen_anchor) if screen_anchor != Vector2.ZERO else Vector2.ZERO
	zoom_factor = clampf(zoom_factor*factor,0.75,2.4)
	_update_camera()
	if screen_anchor != Vector2.ZERO:
		pan += (screen_anchor-world.to_global(before))/ui_scale
		_clamp_pan()
		_update_camera()


func _clamp_pan() -> void:
	pan.x = clampf(pan.x,-frame.size.x*0.7,frame.size.x*0.7)
	pan.y = clampf(pan.y,-frame.size.y*0.7,frame.size.y*0.7)


func _unhandled_input(event: InputEvent) -> void:
	if direction == "menu":
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			set_direction("menu")
		elif event.keycode == KEY_HOME:
			reset_camera()
		elif event.keycode == KEY_TAB:
			set_direction("B" if direction == "A" else "A")
	if panel != null:
		return
	if event is InputEventMouseButton:
		if event.device == -1:
			return
		if not event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_MIDDLE]:
			dragging = false
			if not moved and frame.has_point(event.position/ui_scale):
				_select_at(event.position)
			return
		if not frame.has_point(event.position/ui_scale):
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(1.1,event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(1/1.1,event.position)
		elif event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_MIDDLE]:
			dragging = event.pressed
			if dragging:
				pointer_start = event.position
				pointer_last = event.position
				moved = false
			elif not moved:
				_select_at(event.position)
	if event is InputEventMouseMotion and dragging:
		if event.device == -1:
			return
		var delta: Vector2 = event.position-pointer_last
		pointer_last = event.position
		moved = moved or pointer_start.distance_to(event.position)>8*ui_scale
		pan += delta/ui_scale
		_clamp_pan()
		_update_camera()
	if event is InputEventScreenTouch:
		if event.pressed and frame.has_point(event.position/ui_scale):
			touches[event.index] = event.position
			if touches.size() == 1:
				pointer_start = event.position
				moved = false
			else:
				moved = true
		elif not event.pressed:
			if touches.has(event.index) and touches.size()==1 and not moved and not event.canceled:
				_select_at(event.position)
			touches.erase(event.index)
	if event is InputEventScreenDrag and touches.has(event.index):
		var old: Vector2 = touches[event.index]
		touches[event.index] = event.position
		moved = true
		if touches.size() == 1:
			pan += (event.position-old)/ui_scale
			_clamp_pan()
			_update_camera()
		elif touches.size() == 2:
			var keys := touches.keys()
			var other: Vector2 = touches[keys[0] if keys[1]==event.index else keys[1]]
			var old_distance := old.distance_to(other)
			if old_distance>8:
				_zoom(event.position.distance_to(other)/old_distance,(event.position+other)/2)
	if event is InputEventMagnifyGesture:
		_zoom(event.factor,event.position)
	if event is InputEventPanGesture:
		pan -= event.delta*8
		_clamp_pan()
		_update_camera()


func _select_at(position_on_screen: Vector2) -> void:
	var plot: int = world.plot_at(world.unproject(world.to_local(position_on_screen)))
	world.selected_plot = plot
	world.queue_redraw()
	if plot >= 0:
		note.text = tr("Canteiro %02d • estudo de silhueta e estágio visual") % (plot+1)
	else:
		note.text = tr("Um lugar para crescer • arraste para explorar")


func _open_preview(title: String) -> void:
	if panel != null:
		return
	panel = PanelContainer.new()
	panel.position = Vector2((logical_size.x- minf(820,logical_size.x-80))/2,logical_size.y*0.3)
	panel.size = Vector2(minf(820,logical_size.x-80),440)
	panel.add_theme_stylebox_override("panel",style(PAPER,24,GOLD))
	ui.add_child(panel)
	var content := Control.new()
	content.custom_minimum_size = Vector2(panel.size.x-48,460 if portrait else 400)
	panel.add_child(content)
	label_at(title,Rect2(12,4,600,70),42,INK,content)
	label_at("PRÉVIA DE COMPOSIÇÃO",Rect2(14,82,650,40),22,MUTED,content)
	var descriptions := {
		"Loja": "Sementes  /  Decoração  /  Temas\nUm pequeno mercado para uma grande fazenda.",
		"Amigos": "Um jardim cheio de encontros.\nVisitar  /  Ajudar  /  Compartilhar",
		"Inventário": "Colheitas  /  Materiais  /  Decorações\nTudo encontra seu lugar."
	}
	var description := label_at(descriptions[title],Rect2(14,151,730,125),34 if portrait else 27,INK,content)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button_at("Voltar à fazenda",Rect2(12,292,content.custom_minimum_size.x-24,132 if portrait else 70),_close_preview,true,content)


func _close_preview() -> void:
	if panel != null:
		panel.queue_free()
		panel = null


func _draw() -> void:
	var viewport := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO,viewport),Color("e7ead3"))
	# Light paper-like backdrop with quiet contour lines, independent of camera.
	for i in range(18):
		var y := float(i)*95*ui_scale
		draw_line(Vector2(0,y),Vector2(viewport.x,y+viewport.x*0.09),Color(0.6,0.66,0.48,0.06),1)
