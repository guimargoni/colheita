extends "res://scenes/experience/experience.gd"
## Deliberately small art study, reusing the approved session-only interaction model.

const ArtGarden = preload("res://scripts/visual/art_garden.gd")
var skin: Texture2D
var before_mode: bool = false
var review_audio: Node

func _ready() -> void:
	if ResourceLoader.exists("res://assets/art/g05/ui_atlas_v1.png"):
		skin = load("res://assets/art/g05/ui_atlas_v1.png")
		var art_theme := Theme.new()
		art_theme.set_stylebox("panel","TooltipPanel",skin_style(Rect2(1050,640,455,222)))
		art_theme.set_color("font_color","TooltipLabel",INK)
		art_theme.set_font_size("font_size","TooltipLabel",24)
		theme = art_theme
	super._ready()
	world_layer.remove_child(garden)
	garden.queue_free()
	garden = ArtGarden.new()
	garden.demo = demo
	world = garden
	world_layer.add_child(world)
	# This sample intentionally has four plots. No other simulated plots run hidden.
	demo.config = demo.config.duplicate(true)
	demo.config.seeds.resize(2)
	reset_sample()
	sound.sfx_enabled = false
	sound.set_music(false)
	review_audio = preload("res://scripts/audio/review_audio.gd").new()
	add_child(review_audio)
	demo.acted.connect(func(_id: int, action: String) -> void: review_audio.play(action))
	_layout()
	frame_camera()

func reset_sample() -> void:
	var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/sample.json"))
	demo.config.initial_states = definition.initial_states
	demo.reset()
	for id in range(4):
		demo.plots[id].seed = definition.seed_indices[id]
	_cancel_input()
	if is_instance_valid(garden):
		garden.queue_redraw()

func skin_style(source: Rect2, color: Color = Color.WHITE) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = skin
	box.region_rect = source
	box.modulate_color = color
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		box.set_texture_margin(side,32)
		box.set_content_margin(side,12)
	return box

func button_at(text: String, area: Rect2, action: Callable, primary: bool = false, parent: Control = null) -> Button:
	var button := super.button_at(text,area,action,primary,parent)
	button.add_theme_font_size_override("font_size",28 if portrait else 23)
	button.tooltip_text = tr(text)
	button.pressed.connect(func() -> void:
		if is_instance_valid(review_audio):
			review_audio.play("button")
	)
	if skin!=null:
		var source := Rect2(35,185,477,160) if primary else Rect2(545,185,480,160)
		button.add_theme_stylebox_override("normal",skin_style(source))
		button.add_theme_stylebox_override("hover",skin_style(source,Color(1.08,1.07,1)))
		button.add_theme_stylebox_override("pressed",skin_style(source,Color("c6d7bc")))
		button.add_theme_stylebox_override("disabled",skin_style(source,Color("9da59a")))
		var icon_regions := {"Semear":Rect2(50,740,200,220),"Regar":Rect2(230,525,260,210),"Ajustes":Rect2(275,750,195,205),"Loja":Rect2(530,750,245,210),"Inventário":Rect2(525,515,215,225),"Amigos":Rect2(740,530,275,205)}
		for key in icon_regions:
			if text.begins_with(key):
				var atlas := AtlasTexture.new()
				atlas.atlas = skin
				atlas.region = icon_regions[key]
				button.icon = atlas
				button.expand_icon = true
				button.add_theme_constant_override("icon_max_width",42 if portrait else 32)
				button.add_theme_constant_override("h_separation",10)
	return button

func _build_hud() -> void:
	tool_buttons.clear()
	var w := logical_size.x
	var h := logical_size.y
	var top_h := 164.0 if portrait else 104.0
	card(Rect2(20,16,w-40,top_h),DARK).mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_at("2.450",Rect2(110,30,235,62),36,PAPER)
	if skin!=null:
		var coin := TextureRect.new()
		var coin_atlas := AtlasTexture.new()
		coin_atlas.atlas = skin
		coin_atlas.region = Rect2(35,540,190,195)
		coin.texture = coin_atlas
		coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coin.position = Vector2(48,36)
		coin.size = Vector2(52,52)
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.add_child(coin)
	label_at("NÍVEL 07 · 320 / 500 XP",Rect2(390,32,460,40),26,Color("f1da91"))
	_xp_bar(Rect2(390,92 if portrait else 82,460 if portrait else 310,14))
	if not portrait:
		label_at("Jardim do Sol",Rect2(850,24,460,52),36,PAPER)
		label_at("Estudo artístico · G0.5",Rect2(850,76,460,32),19,Color("d0d9c2"))
	button_at("Ajustes",Rect2(w-204,30,168,132 if portrait else 72),open_panel.bind("Configurações"))
	frame = Rect2(0,top_h+30,w,h-top_h-(350 if portrait else 175))
	var tool_y := h-300 if portrait else h-102
	var tool_w := (w-72)/4 if portrait else 240.0
	var tool_h := 132.0 if portrait else 78.0
	var start_x := 24.0 if portrait else w-4*(tool_w+12)-20
	_add_tool("seed","Semear\n"+str(demo.config.seeds[demo.selected_seed].name),Rect2(start_x,tool_y,tool_w,tool_h))
	_add_tool("water","Regar [2]",Rect2(start_x+tool_w+8,tool_y,tool_w,tool_h))
	_add_tool("camera","Câmera [3]",Rect2(start_x+2*(tool_w+8),tool_y,tool_w,tool_h))
	button_at("Enquadrar",Rect2(start_x+3*(tool_w+8),tool_y,tool_w,tool_h),frame_camera)
	var titles := ["Loja","Inventário","Amigos"]
	for i in range(3):
		button_at(titles[i],Rect2(24+i*(344 if portrait else 204),h-(148 if portrait else 102),328 if portrait else 192,132 if portrait else 78),open_panel.bind(titles[i]))
	card(Rect2(16,top_h+34,minf(w-32,1048 if portrait else 620),62),PAPER).mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_label = label_at("Colha com um toque. Arraste para cuidar.",Rect2(28,top_h+40,w-56,50),28 if portrait else 22)
	card(Rect2(16,h-(376 if portrait else 170),minf(w-32,1048 if portrait else 720),62),PAPER).mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_label = label_at("Segure para inspecionar · dados de demonstração",Rect2(28,h-(370 if portrait else 164),w-56,54),26 if portrait else 22)
	gesture.threshold = 12*ui_scale
	_refresh()

func _update_camera() -> void:
	if not is_instance_valid(world_layer) or frame.size.y<=0:
		return
	var fit := minf(frame.size.x/1120.0,frame.size.y/880.0)*zoom_factor
	world_layer.position = frame.position*ui_scale
	world_layer.size = frame.size*ui_scale
	world.scale = Vector2.ONE*fit*ui_scale
	world.position = (frame.size*0.5+pan)*ui_scale-Vector2(0,100)*world.scale

func frame_camera() -> void:
	zoom_factor = 1.05
	pan = Vector2.ZERO
	_update_camera()

func hit_at(screen: Vector2) -> int:
	if panel!=null or not frame.has_point(screen/ui_scale) or not world is ArtGarden:
		return -1
	var point := world.to_local(screen)
	var nearest := -1
	var distance := INF
	for id in range(4):
		var center := world.project(ArtGarden.POSITIONS[id])-Vector2(0,48)
		var offset: Vector2 = point-center
		# Enlarged touch bounds; nearest center assigns overlapping margins uniquely.
		if absf(offset.x)<=98 and absf(offset.y)<=70 and offset.length_squared()<distance:
			nearest = id
			distance = offset.length_squared()
	return nearest

func set_before(value: bool) -> void:
	before_mode = value
	garden.before = value
	garden.queue_redraw()

func toggle_halloween() -> void:
	close_panel()
	garden.halloween = not garden.halloween
	demo.plots[3].state = "mature"
	garden.queue_redraw()
	info_label.text = tr("Abóbora Amaldiçoada · conceito sazonal, sem evento ou prêmio real")

func open_panel(title: String) -> void:
	if title in ["Loja","Inventário","Amigos"]:
		super.open_panel(title)
		if skin!=null:
			panel.add_theme_stylebox_override("panel",skin_style(Rect2(1050,50,445,423)))
		if portrait:
			var content: Control = panel.get_child(0)
			var index := 0
			for child in content.get_children():
				if child is Button:
					child.size.y = 132
					if title=="Loja":
						child.position.y = [166,314,510][index]
					index += 1
			content.custom_minimum_size.y = 668
		return
	_cancel_input()
	close_panel()
	panel = PanelContainer.new()
	panel.position = Vector2((logical_size.x-904)/2,(logical_size.y-852)/2)
	panel.size = Vector2(904,852)
	panel.add_theme_stylebox_override("panel",style(PAPER,24,GOLD))
	if skin!=null:
		var modal_skin := skin_style(Rect2(1050,50,445,423))
		for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
			modal_skin.set_content_margin(side,36)
		panel.add_theme_stylebox_override("panel",modal_skin)
	ui.add_child(panel)
	var content := Control.new()
	content.custom_minimum_size = Vector2(832,780)
	panel.add_child(content)
	label_at("Estúdio · G0.5",Rect2(12,0,790,70),40,INK,content)
	var body := label_at("Arte em revisão. Áudio final não produzido.\nOs sons G0.4 são opcionais e temporários.",Rect2(12,80,790,90),27,INK,content)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button_at("Ouvir SFX temporários: "+("sim" if sound.sfx_enabled else "não"),Rect2(12,184,790,100),_sfx_setting,false,content)
	button_at("Movimento reduzido / normal",Rect2(12,298,790,100),_motion_setting,false,content)
	button_at("Abóbora · estudo Halloween",Rect2(12,412,790,100),toggle_halloween,false,content)
	button_at("UI Kit",Rect2(12,526,380,100),show_kit,false,content)
	button_at("Antes / depois",Rect2(412,526,390,100),toggle_before,false,content)
	button_at("Reiniciar",Rect2(12,646,380,110),reset_demo,false,content)
	button_at("Fechar",Rect2(412,646,390,110),close_panel,true,content)
	if portrait:
		var ys := [184,332,480,628,628,776,776]
		var index := 0
		for child in content.get_children():
			if child is Button:
				child.position.y = ys[index]
				child.size.y = 132
				index += 1
		content.custom_minimum_size.y = 932
		panel.size.y = 1004
		panel.position.y = (logical_size.y-panel.size.y)/2

func toggle_before() -> void:
	set_before(not before_mode)
	close_panel()
	info_label.text = tr("Geometria G0.4 · mesma câmera e região") if before_mode else tr("Sprites G0.5 · arte em revisão")

func show_kit() -> void:
	close_panel()
	open_panel("UI Kit")
	# Reuse the studio modal frame, replace its contents with live state examples.
	var content: Control = panel.get_child(0)
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	label_at("UI Kit · Jardim do Sol",Rect2(12,0,790,64),38,INK,content)
	button_at("Principal",Rect2(12,100,380,110),close_panel,true,content)
	button_at("Secundário",Rect2(412,100,390,110),close_panel,false,content)
	var disabled := button_at("Indisponível",Rect2(12,230,380,110),func() -> void: pass,false,content)
	disabled.disabled = true
	var pressed := button_at("Pressionado",Rect2(412,230,390,110),func() -> void: pass,true,content)
	pressed.toggle_mode = true
	pressed.set_pressed_no_signal(true)
	label_at("● 2.450   ·   XP 320 / 500",Rect2(12,360,790,50),30,INK,content)
	button_at("Morango · semente selecionada",Rect2(12,430,790,110),select_seed.bind(0),true,content)
	label_at("✓ Pronto para colher · toque único",Rect2(12,558,790,70),28,INK,content)
	button_at("Voltar",Rect2(12,646,790,110),close_panel,true,content)
	if portrait:
		var ys := [100,100,248,248,480,746]
		var index := 0
		for child in content.get_children():
			if child is Button:
				child.position.y = ys[index]
				child.size.y = 132
				index += 1
			elif child is Label:
				if child.text.begins_with("●"):
					child.position.y = 408
				elif child.text.begins_with("✓"):
					child.position.y = 630

func reset_demo() -> void:
	reset_sample()
	close_panel()
	status_label.text = tr("Nova manhã · quatro canteiros para experimentar")

func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F8:
		toggle_before()
		return
	if event is InputEventKey and event.pressed and not event.echo and panel==null and event.keycode in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:
		var step: int = {KEY_LEFT:-1,KEY_RIGHT:1,KEY_UP:-2,KEY_DOWN:2}[event.keycode]
		keyboard_plot = clampi(keyboard_plot+step,0,3)
		garden.selected_plot = keyboard_plot
		inspect_plot(keyboard_plot)
		return
	super._shortcut_input(event)
	keyboard_plot = clampi(keyboard_plot,0,3)

func _draw() -> void:
	draw_rect(get_viewport_rect(),Color("92a96e"))
