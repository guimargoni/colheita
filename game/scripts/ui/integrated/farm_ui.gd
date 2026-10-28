extends "res://scripts/ui/g1v/living_economy_ui.gd"
func crop_card(body: Control,id: String) -> VBoxContainer:
	return item_card(body,scene.world.crop_texture(id,"mature"),scene.service.catalog.entries[id].name)

func open_inventory() -> void:
	super.open_inventory()
	if scene.panel==null: return
	var scrolls: Array[Node] = scene.panel.find_children("*","ScrollContainer",true,false)
	if scrolls.is_empty(): return
	var body: VBoxContainer = scrolls[0].get_child(0)
	arrange_cards(body)
	label(body,"Produção e buquês")
	for id in scene.service.state.features.goods:
		var count: int = int(scene.service.state.features.goods[id])
		var name: String = {"egg":"Ovos","milk":"Leite","honey":"Mel","wool":"Lã","bouquet":"Buquês"}.get(id,id)
		label(body,"%s · %d guardados"%[name,count])
		button(body,"Vender 1 "+name,sell_feature.bind(id),count<1)
func sell_feature(id: String) -> void:
	scene.feature_action("sell_goods",{"kind":id,"quantity":1})
	open_inventory()

func category_filter(parent: Control) -> void:
	super.category_filter(parent)
	var selector: OptionButton = parent.get_child(parent.get_child_count()-1)
	selector.custom_minimum_size.y = 96 if scene.portrait else 56
	for state in ["normal","hover","pressed","disabled"]:
		selector.add_theme_stylebox_override(state,scene.kit.surface(Color("fffaf0")))
	for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		selector.add_theme_color_override(state,scene.kit.INK)
	var popup := selector.get_popup()
	popup.add_theme_stylebox_override("panel",scene.kit.surface(scene.kit.PAPER))
	popup.add_theme_font_size_override("font_size",26)
	popup.add_theme_color_override("font_color",scene.kit.INK)

func build_header() -> void:
	var icon: TextureRect = scene.kit.illustration(scene.hud,scene.kit.item_icon("coin"),56)
	icon.position = Vector2(32,28)
	money = scene.kit.label("",Rect2(92,35,210,34),28,scene.kit.PAPER)
	level_label = scene.kit.label("",Rect2(306,35,350,34),22,scene.kit.PAPER)
	xp_bar = ProgressBar.new(); xp_bar.position = Vector2(96,83); xp_bar.size = Vector2(540 if scene.portrait else 440,9)
	xp_bar.show_percentage = false; xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for entry in [["background",Color("264b45")],["fill",Color("efc66a")]]:
		var style := StyleBoxFlat.new(); style.bg_color = entry[1]; style.set_corner_radius_all(4)
		xp_bar.add_theme_stylebox_override(entry[0],style)
	scene.hud.add_child(xp_bar)
	notice = scene.kit.label("",Rect2(40,128,800,36),22); notice.visible = false
	tick(0)
func tick(delta: float) -> void:
	super.tick(delta)
	if is_instance_valid(money): money.text = str(int(round(shown_coins)))
func shell(title: String) -> VBoxContainer:
	var body := super.shell(title)
	var width: float = minf(scene.logical.x-48,1000 if scene.portrait else 920)
	var height: float = minf(scene.logical.y-80,1280 if scene.portrait else 760)
	scene.panel.size = Vector2(width,height)
	scene.panel.position = (scene.logical-Vector2(width,height))/2
	scene.panel.add_theme_stylebox_override("panel",scene.kit.surface(scene.kit.paper))
	scene.panel.set_meta("game_shell",true)
	return body
func fit_open_panel() -> void:
	if scene.panel==null or not scene.panel.get_meta("game_shell",false): return
	var target := Vector2(minf(scene.logical.x-48,1000 if scene.portrait else 920),minf(scene.logical.y-80,1280 if scene.portrait else 760))
	scene.panel.size = target
	scene.panel.position = (scene.logical-scene.panel.size)/2
func label(parent: Control,text: String) -> void:
	super.label(parent,text)
	var l: Label = parent.get_child(parent.get_child_count()-1)
	l.add_theme_font_size_override("font_size",22 if scene.portrait else 20)
func button(parent: Control,text: String,action: Callable,disabled: bool = false) -> Button:
	var b: Button = super.button(parent,text,action,disabled)
	b.custom_minimum_size.y = 84 if scene.portrait else 56
	return b
func item_card(parent: Control,texture: Texture2D,title: String) -> VBoxContainer:
	var panel := PanelContainer.new(); panel.add_theme_stylebox_override("panel",scene.kit.surface(Color("fffaf0")))
	parent.add_child(panel)
	var column := VBoxContainer.new(); column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation",10); panel.add_child(column)
	var row := HBoxContainer.new(); column.add_child(row)
	scene.kit.illustration(row,texture,88)
	var heading := Label.new(); heading.text = title; heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL; heading.add_theme_color_override("font_color",scene.kit.INK)
	heading.add_theme_font_size_override("font_size",26); row.add_child(heading)
	return column

func arrange_cards(body: VBoxContainer) -> void:
	var cards: Array[Node] = []
	for child in body.get_children():
		if child is PanelContainer: cards.append(child)
	if cards.is_empty(): return
	var grid := GridContainer.new(); grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation",14); grid.add_theme_constant_override("v_separation",14)
	body.add_child(grid)
	for card in cards:
		card.reparent(grid); card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size.x = 410 if scene.portrait else 382
func open_shop() -> void:
	super.open_shop()
	var scrolls: Array[Node] = scene.panel.find_children("*","ScrollContainer",true,false)
	if not scrolls.is_empty(): arrange_cards(scrolls[0].get_child(0))
