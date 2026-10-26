extends "res://scripts/ui/cultures/culture_ui.gd"
## Reuse transactions, filters, receipts and inventories; change only presentation.
func build_header() -> void:
	money = scene.kit.label("",Rect2(44,38,360,42),30,scene.kit.PAPER)
	level_label = scene.kit.label("",Rect2(420 if scene.portrait else 360,38,430 if scene.portrait else 280,42),26,scene.kit.PAPER)
	xp_bar = ProgressBar.new()
	xp_bar.position = Vector2(44,104 if scene.portrait else 94)
	xp_bar.size = Vector2(990 if scene.portrait else 612,12)
	xp_bar.show_percentage = false
	xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for entry in [["background",Color("183e39")],["fill",Color("e9bb59")]]:
		var style := StyleBoxFlat.new()
		style.bg_color = entry[1]
		style.set_corner_radius_all(5)
		xp_bar.add_theme_stylebox_override(entry[0],style)
	scene.hud.add_child(xp_bar)
	notice = scene.kit.label("",Rect2(44,logical_notice_y(),990,36),21)
	notice.visible = false
	tick(0)

func logical_notice_y() -> float:
	return 156 if scene.portrait else 140

func shell(title: String) -> VBoxContainer:
	scene.cancel_input()
	scene.immediate_close()
	var shade := ColorRect.new()
	shade.color = Color(0.09,0.19,0.17,0.26 if scene.presentation=="B" else 0.15)
	shade.size = scene.logical
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	scene.hud.add_child(shade)
	var panel := PanelContainer.new()
	var width: float = 1016 if scene.portrait else 1040
	var height: float = minf(1500 if scene.portrait else 830,scene.logical.y-64)
	panel.position = (scene.logical-Vector2(width,height))/2
	panel.size = Vector2(width,height)
	panel.set_meta("shade",shade)
	panel.tree_exiting.connect(shade.queue_free)
	panel.add_theme_stylebox_override("panel",scene.kit.surface(scene.kit.PAPER))
	scene.hud.add_child(panel)
	scene.panel = panel
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",18)
	panel.add_child(column)
	var heading := Label.new()
	heading.text = tr(title)
	heading.add_theme_color_override("font_color",scene.kit.INK)
	heading.add_theme_font_size_override("font_size",34)
	column.add_child(heading)
	var summary := Label.new()
	summary.text = tr("%d moedas   ·   nível %d")%[int(scene.service.state.economy.coins),int(scene.service.state.economy.level)]
	summary.add_theme_color_override("font_color",Color("527368"))
	summary.add_theme_font_size_override("font_size",24)
	column.add_child(summary)
	var feedback := Label.new()
	feedback.text = note
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_font_size_override("font_size",22)
	feedback.add_theme_color_override("font_color",scene.kit.INK)
	feedback.visible = not note.is_empty()
	column.add_child(feedback)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",20)
	scroll.add_child(body)
	button(column,"Voltar à fazenda",scene.close_studio)
	if scene.world.motion and scene.world.intensity>0:
		panel.modulate.a = 0
		panel.position.y += 22
		var tween := panel.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel,"modulate:a",1.0,0.18)
		tween.tween_property(panel,"position:y",panel.position.y-22,0.18)
	return body

func crop_card(body: Control, id: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",scene.kit.surface(Color("fffaf0")))
	body.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	panel.add_child(column)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",18)
	column.add_child(row)
	var art: Dictionary = scene.world.expanded
	var crop: Dictionary = scene.service.catalog.entries[id]
	var key: String = crop.stages.back().key
	var item: Dictionary = art.sprites.get(key,{}) if art.sockets.has(id) else scene.world.definition.crops.get(key,{})
	if not item.is_empty():
		var texture := AtlasTexture.new()
		texture.atlas = scene.world.NEW_CROPS if art.sockets.has(id) else scene.world.CROPS
		var rect: Array = item.rect
		texture.region = Rect2(rect[0],rect[1],rect[2],rect[3])
		var image := TextureRect.new()
		image.texture = texture
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(104,104)
		row.add_child(image)
	var name_label := Label.new()
	name_label.text = tr(crop.name)
	name_label.add_theme_font_size_override("font_size",28)
	name_label.add_theme_color_override("font_color",scene.kit.INK)
	row.add_child(name_label)
	return column

func open_shop() -> void:
	mode = "shop"
	var body := shell("Sementes para sua próxima colheita")
	category_filter(body)
	label(body,"Sementes por compra")
	amount(body,buy_quantity,999,func(value: float) -> void: buy_quantity = int(value); open_shop())
	for id in scene.service.catalog.ids:
		var crop: Dictionary = scene.service.catalog.entries[id]
		if filter_category!="all" and crop.category!=filter_category: continue
		var card := crop_card(body,id)
		var rule: Dictionary = scene.service.economy_config.crops[id]
		label(card,"%d s  ·  %d produtos × %d colheitas"%[int(crop.growth_seconds),int(crop.yield_quantity),int(crop.harvest_count)])
		var locked: bool = id not in scene.service.state.economy.unlocks
		var availability: Dictionary = Seasons.check_purchase(scene.service.state,{"type":"buy_seeds","crop_id":id,"quantity":buy_quantity},scene.service.events,scene.service.clock.calendar_seconds())
		var unavailable: bool = not availability.ok
		label(card,"Na bolsa: %d sementes"%int(scene.service.state.inventory.seeds.get(id,0)))
		button(card,"Nível %d"%int(rule.unlock_level) if locked else "Fora do período / limite atingido" if unavailable else "Comprar %d · %d moedas"%[buy_quantity,buy_quantity*int(rule.seed_price)],buy.bind(id),locked or unavailable or int(scene.service.state.economy.shop_stock[id])<buy_quantity)

func open_inventory() -> void:
	mode = "inventory"
	var body := shell("Sua colheita, guardada com carinho")
	category_filter(body)
	for i in range(scene.service.catalog.ids.size()):
		var id: String = scene.service.catalog.ids[i]
		var crop: Dictionary = scene.service.catalog.entries[id]
		if filter_category!="all" and crop.category!=filter_category: continue
		var card := crop_card(body,id)
		var count: int = int(scene.service.state.inventory.products.get(id,0))
		var seeds: int = int(scene.service.state.inventory.seeds.get(id,0))
		label(card,"%d sementes   ·   %d produtos guardados"%[seeds,count])
		button(card,"Semear",scene.select_seed.bind(i),seeds<1 or id not in scene.service.state.economy.unlocks)
		quantities[id] = mini(int(quantities.get(id,1)),maxi(1,count))
		var sell := button(card,"Vender %d · +%d moedas"%[int(quantities[id]),int(quantities[id])*int(scene.service.economy_config.crops[id].sell_value)],sell_one.bind(id),count<1)
		amount(card,int(quantities[id]),mini(count,999),func(value: float) -> void: quantities[id] = int(value); sell.text = "Vender %d · +%d moedas"%[int(value),int(value)*int(scene.service.economy_config.crops[id].sell_value)])
		var check := CheckBox.new()
		check.text = "Incluir %d produtos na venda selecionada"%count
		check.button_pressed = bool(selected.get(id,false))
		check.custom_minimum_size.y = 110 if scene.portrait else 56
		check.add_theme_font_size_override("font_size",23)
		check.add_theme_color_override("font_color",scene.kit.INK)
		check.toggled.connect(func(on: bool) -> void: selected[id] = on)
		card.add_child(check)
	button(body,"Vender todos os produtos selecionados",sell_selected)

func on_harvest(action: String) -> void:
	if action=="harvest": note = tr("Colheita guardada · XP recebida")

func tick(delta: float) -> void:
	# Convert to the parent blend with exponential elapsed-time interpolation.
	super.tick((1-exp(-9*delta))/9 if delta>0 else 0.0)
