extends "res://scenes/comparison/comparison.gd"
## G0.4 presentation. Simulation and gesture arbitration live outside the scene.

const GardenView = preload("res://scripts/visual/garden_view.gd")
const LocalGarden = preload("res://scripts/prototype/local_garden.gd")
const GardenGesture = preload("res://scripts/prototype/garden_gesture.gd")
const PrototypeAudio = preload("res://scripts/audio/prototype_audio.gd")

var demo: LocalGarden
var gesture: GardenGesture
var garden: GardenView
var sound: PrototypeAudio
var status_label: Label
var info_label: Label
var tool_buttons: Dictionary = {}
var hover_id: int = -1
var hover_elapsed: float = 0
var keyboard_plot: int = 0
var space_pan: bool = false
var session_time: float = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	demo = LocalGarden.new()
	gesture = GardenGesture.new()
	gesture.picker = hit_at
	gesture.action_requested.connect(_act)
	gesture.inspection_requested.connect(inspect_plot)
	gesture.pan_requested.connect(_pan_camera)
	gesture.zoom_requested.connect(_zoom)
	world_layer = Control.new()
	world_layer.clip_contents = true
	world_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world_layer)
	garden = GardenView.new()
	garden.demo = demo
	world = garden
	world_layer.add_child(world)
	sound = PrototypeAudio.new()
	add_child(sound)
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)
	demo.acted.connect(_feedback)
	demo.changed.connect(_refresh)
	get_viewport().size_changed.connect(_on_resize)
	get_window().focus_exited.connect(_cancel_input)
	set_direction("A")
	frame_camera()


func _on_resize() -> void:
	_cancel_input()
	_layout()
	frame_camera()


func _cancel_input() -> void:
	gesture.cancel()
	space_pan = false


func _process(delta: float) -> void:
	session_time += delta
	gesture.tick(delta)
	demo.tick(delta)
	if gesture.mode=="idle" and hover_id>=0 and panel==null:
		hover_elapsed += delta
		if hover_elapsed>=0.45 and hover_elapsed-delta<0.45:
			inspect_plot(hover_id)


func button_at(text: String, area: Rect2, action: Callable, primary: bool = false, parent: Control = null) -> Button:
	var button := super.button_at(text,area,action,primary,parent)
	button.pressed.connect(func() -> void: sound.play_cue("button"))
	return button


func _build_hud() -> void:
	world.visible = true
	tool_buttons.clear()
	var w := logical_size.x
	var h := logical_size.y
	if portrait:
		card(Rect2(28,24,w-56,144),DARK)
		label_at("●  2.450",Rect2(60,42,380,80),46,PAPER)
		label_at("NÍVEL 07",Rect2(590,41,370,55),34,Color("f1da91"))
		_xp_bar(Rect2(590,105,370,16))
		label_at("Bom dia, fazendeiro!",Rect2(28,204,820,66),45)
		label_at("Jardim do Sol  /  sessão local",Rect2(30,282,820,44),28,MUTED)
		button_at("⚙",Rect2(w-160,190,132,132),open_panel.bind("Configurações")).tooltip_text = tr("Configurações")
		frame = Rect2(0,352,w,h-825)
		button_at("+",Rect2(w-164,366,132,132),_zoom.bind(1.18,Vector2.ZERO))
		button_at("−",Rect2(w-164,510,132,132),_zoom.bind(0.85,Vector2.ZERO))
		var y := h-350
		_add_tool("seed","Sementes\n"+str(demo.config.seeds[demo.selected_seed].name),Rect2(28,y,244,132))
		_add_tool("water","Regador",Rect2(288,y,244,132))
		_add_tool("camera","Câmera",Rect2(548,y,244,132))
		button_at("Enquadrar",Rect2(808,y,244,132),frame_camera)
		for i in range(3):
			var title: String = ["Loja","Inventário","Amigos"][i]
			button_at(title,Rect2(74+i*316,h-180,300,132),open_panel.bind(title))
		status_label = label_at("Toque para colher • deslize para cuidar",Rect2(30,h-430,w-60,60),28)
		info_label = label_at("Segure um canteiro para saber mais",Rect2(30,frame.end.y-90,w-60,80),27,INK)
	else:
		card(Rect2(28,26,248,92),DARK)
		label_at("●  2.450",Rect2(54,37,220,60),33,PAPER)
		card(Rect2(294,26,306,92))
		label_at("NÍVEL 07  ·  320 / 500 XP",Rect2(318,35,258,40),22)
		_xp_bar(Rect2(318,83,250,10))
		label_at("Jardim do Sol",Rect2(660,24,760,52),38)
		label_at("Uma pequena fazenda, cheia de vida.",Rect2(662,82,760,36),21,MUTED)
		button_at("Configurações",Rect2(w-270,30,240,80),open_panel.bind("Configurações"))
		frame = Rect2(0,140,w,h-340)
		for i in range(3):
			var title: String = ["Loja","Inventário","Amigos"][i]
			button_at(title,Rect2(28+i*226,h-110,210,82),open_panel.bind(title))
		_add_tool("seed","Sementes · "+str(demo.config.seeds[demo.selected_seed].name),Rect2(756,h-110,292,82))
		_add_tool("water","Regador [2]",Rect2(1064,h-110,210,82))
		_add_tool("camera","Câmera [3]",Rect2(1290,h-110,210,82))
		button_at("Enquadrar",Rect2(1516,h-110,190,82),frame_camera)
		button_at("−",Rect2(w-178,h-110,68,82),_zoom.bind(0.85,Vector2.ZERO))
		button_at("+",Rect2(w-94,h-110,68,82),_zoom.bind(1.18,Vector2.ZERO))
		status_label = label_at("Toque para colher • arraste pelos canteiros para cuidar",Rect2(32,h-183,1130,54),25)
		info_label = label_at("Hover ou toque prolongado para inspecionar",Rect2(32,150,600,80),22,INK)
	gesture.threshold = 12*ui_scale
	_refresh()


func _xp_bar(area: Rect2) -> void:
	var bar := ProgressBar.new()
	bar.position = area.position
	bar.size = area.size
	bar.value = 64
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background",style(Color("cbd4b5"),6))
	bar.add_theme_stylebox_override("fill",style(Color("d6ab60"),6))
	ui.add_child(bar)


func _add_tool(key: String, title: String, area: Rect2) -> void:
	var button := button_at(title,area,choose_tool.bind(key),demo.tool==key)
	if portrait and key=="seed":
		button.add_theme_font_size_override("font_size",34)
	tool_buttons[key] = button


func choose_tool(key: String) -> void:
	_cancel_input()
	if key=="seed" and demo.tool=="seed":
		demo.selected_seed = (demo.selected_seed+1)%demo.config.seeds.size()
	demo.tool = key
	gesture.camera_tool = key=="camera"
	_layout()
	status_label.text = tr("Semente: ")+str(demo.config.seeds[demo.selected_seed].name) if key=="seed" else tr("Regador selecionado • deslize nos canteiros com sede") if key=="water" else tr("Câmera livre • nenhum canteiro será alterado")


func _refresh() -> void:
	if is_instance_valid(garden):
		garden.queue_redraw()


func frame_camera() -> void:
	zoom_factor = 2.05 if portrait else 1.25
	pan = Vector2.ZERO
	_update_camera()
	var center := world.to_global(world.project(Vector2(4.0,4.3)))
	pan += frame.get_center()-center/ui_scale
	_clamp_pan()
	_update_camera()


func _pan_camera(delta: Vector2) -> void:
	pan += delta/ui_scale
	_clamp_pan()
	_update_camera()


func hit_at(screen: Vector2) -> int:
	if not frame.has_point(screen/ui_scale) or panel!=null:
		return -1
	var ground := world.unproject(world.to_local(screen)+Vector2(0,9))
	# Fill the small gaps between beds. Voronoi selection never maps to two plots.
	var local := ground-Vector2(2.7,3.0)
	if local.x>=-0.04 and local.y>=-0.04 and local.x<4.24 and local.y<4.24:
		return clampi(int(floor((local.y+0.04)/1.06)),0,3)*4+clampi(int(floor((local.x+0.04)/1.06)),0,3)
	return -1


func _act(id: int) -> void:
	var action := demo.act(id)
	if action.is_empty() and id>=0:
		inspect_plot(id)


func _feedback(id: int, action: String) -> void:
	garden.selected_plot = id
	garden.feedback(id,action)
	sound.play_cue(action)
	status_label.text = {"plant":"Plantado! Uma gotinha de água agora?", "harvest":"Colhido! Que beleza de colheita.", "water":"Regado! Agora é só crescer."}[action]
	info_label.text = demo.describe(id)


func inspect_plot(id: int) -> void:
	if id<0:
		return
	garden.hover_plot = id
	garden.queue_redraw()
	info_label.text = demo.describe(id)


func _input(event: InputEvent) -> void:
	# Capture an active map gesture across GUI boundaries and out-of-map release.
	if gesture==null or gesture.mode=="idle":
		return
	if event is InputEventMouseButton and not event.pressed and event.device!=-1:
		gesture.release(event.position,0,not frame.has_point(event.position/ui_scale))
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and event.device!=-1:
		gesture.move(event.position,0)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		gesture.move(event.position,event.index)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if frame.has_point(event.position/ui_scale):
				gesture.press(event.position,event.index)
			else:
				gesture.cancel()
		else:
			gesture.release(event.position,event.index,event.canceled or not frame.has_point(event.position/ui_scale))
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if panel!=null:
		return
	if event is InputEventMouseButton and event.device!=-1:
		if not frame.has_point(event.position/ui_scale):
			return
		if event.button_index==MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(1.1,event.position)
		elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(1/1.1,event.position)
		elif event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_MIDDLE,MOUSE_BUTTON_RIGHT]:
			gesture.press(event.position,0,event.button_index!=MOUSE_BUTTON_LEFT or space_pan)
	elif event is InputEventMouseMotion:
		var id := hit_at(event.position)
		if id!=hover_id:
			hover_id = id
			hover_elapsed = 0
			garden.hover_plot = id
			garden.queue_redraw()
	elif event is InputEventScreenTouch and event.pressed and frame.has_point(event.position/ui_scale):
		gesture.press(event.position,event.index)
	elif event is InputEventMagnifyGesture:
		gesture.cancel()
		_zoom(event.factor,event.position)
	elif event is InputEventPanGesture:
		gesture.cancel()
		_pan_camera(-event.delta*8)


func _shortcut_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if event.keycode==KEY_SPACE:
		space_pan = event.pressed
	if not event.pressed or event.echo:
		return
	if event.keycode==KEY_ESCAPE:
		close_panel()
		_cancel_input()
	elif panel==null:
		match event.keycode:
			KEY_1: choose_tool("seed")
			KEY_2: choose_tool("water")
			KEY_3: choose_tool("camera")
			KEY_HOME: frame_camera()
			KEY_LEFT: keyboard_plot = maxi(0,keyboard_plot-1)
			KEY_RIGHT: keyboard_plot = mini(15,keyboard_plot+1)
			KEY_UP: keyboard_plot = maxi(0,keyboard_plot-4)
			KEY_DOWN: keyboard_plot = mini(15,keyboard_plot+4)
			KEY_ENTER:
				if get_viewport().gui_get_focus_owner()==null:
					_act(keyboard_plot)
		if event.keycode in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:
			garden.selected_plot = keyboard_plot
			inspect_plot(keyboard_plot)


func open_panel(title: String) -> void:
	_cancel_input()
	close_panel()
	panel = PanelContainer.new()
	panel.position = Vector2((logical_size.x-880)/2,logical_size.y*0.23)
	panel.size = Vector2(880,680)
	panel.add_theme_stylebox_override("panel",style(PAPER,24,GOLD))
	ui.add_child(panel)
	var content := Control.new()
	content.custom_minimum_size = Vector2(832,640)
	panel.add_child(content)
	label_at(title,Rect2(12,6,780,68),44,INK,content)
	if title=="Configurações":
		button_at("Música: "+("ligada" if sound.music_enabled else "desligada"),Rect2(12,100,790,110),_music_setting,true,content)
		button_at("Efeitos: "+("ligados" if sound.sfx_enabled else "desligados"),Rect2(12,226,790,110),_sfx_setting,false,content)
		button_at("Movimento: "+("reduzido" if not garden.animation_enabled else "normal"),Rect2(12,352,790,110),_motion_setting,false,content)
		button_at("Reiniciar",Rect2(12,478,470,132),reset_demo,false,content)
		button_at("Fechar",Rect2(502,478,300,132),close_panel,true,content)
	elif title=="Loja":
		label_at("Escolha o que quer cultivar",Rect2(12,92,790,60),32,INK,content)
		for i in range(demo.config.seeds.size()):
			button_at(str(demo.config.seeds[i].name)+"  ·  Selecionar",Rect2(12,166+i*112,790,100),select_seed.bind(i),demo.selected_seed==i,content)
		button_at("Voltar à fazenda",Rect2(12,510,790,110),close_panel,true,content)
	else:
		var text := "Colheitas desta sessão: %d\n\nSementes à vontade para experimentar.\nMoedas e XP são apenas uma prévia." % demo.harvest_count if title=="Inventário" else "Lia  ·  Jardim das Flores\n\nCaio  ·  Recanto do Ipê\n\nUm lugar para os encontros que virão."
		var body := label_at(text,Rect2(12,120,790,330),34,INK,content)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button_at("Voltar à fazenda",Rect2(12,510,790,110),close_panel,true,content)


func close_panel() -> void:
	if panel!=null:
		ui.remove_child(panel)
		panel.queue_free()
		panel = null


func select_seed(index: int) -> void:
	demo.selected_seed = index
	demo.tool = "seed"
	gesture.camera_tool = false
	close_panel()
	_layout()


func _music_setting() -> void:
	sound.set_music(not sound.music_enabled)
	open_panel("Configurações")


func _sfx_setting() -> void:
	sound.sfx_enabled = not sound.sfx_enabled
	open_panel("Configurações")


func _motion_setting() -> void:
	garden.animation_enabled = not garden.animation_enabled
	open_panel("Configurações")


func reset_demo() -> void:
	_cancel_input()
	demo.reset()
	close_panel()
	status_label.text = tr("Uma nova manhã! Experimente outra vez.")


func _draw() -> void:
	draw_rect(get_viewport_rect(),Color("8bad69"))
