extends RefCounted
## Presentation only: prices/rewards are recomputed by the service.
const Rules = preload("res://scripts/domain/economy/economy_rules.gd")
var scene: Control
var money: Label
var level_label: Label
var xp_bar: ProgressBar
var notice: Label
var shown_coins: float = -1
var shown_xp: float = -1
var last_level: int = 1
var quantities: Dictionary = {}
var selected: Dictionary = {}
var buy_quantity: int = 1
var busy: bool = false
var mode: String = ""
var note: String = ""
var toast: Label
var toast_tween: Tween

func _init(owner_scene: Control) -> void:
	scene = owner_scene
	if not scene.service.state.is_empty():
		last_level = int(scene.service.state.economy.level)

func build_header() -> void:
	var kit: RefCounted = scene.kit
	money = kit.label("",Rect2(44,18,280,42),28,kit.PAPER)
	level_label = kit.label("",Rect2(330,18,280,42),24,kit.PAPER)
	xp_bar = ProgressBar.new()
	xp_bar.position = Vector2(44,108 if scene.portrait else 100)
	xp_bar.size = Vector2(540 if scene.portrait else 520,20)
	xp_bar.show_percentage = false
	xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xp_bar.modulate = Color("f2c34e")
	scene.hud.add_child(xp_bar)
	notice = kit.label("",Rect2(44,132 if scene.portrait else 4,620,64),26 if scene.portrait else 22,kit.INK)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if not scene.portrait:
		notice.position = Vector2(856,4)
	tick(0)

func tick(delta: float) -> void:
	if scene.service.state.is_empty() or not is_instance_valid(money):
		return
	var e: Dictionary = scene.service.state.economy
	var motion: bool = scene.world.motion if is_instance_valid(scene.world) else false
	var blend: float = minf(1,delta*9) if motion and shown_coins>=0 else 1.0
	shown_coins = lerpf(shown_coins,float(e.coins),blend)
	shown_xp = lerpf(shown_xp,float(e.xp),blend)
	if absf(shown_coins-e.coins)<0.2:
		shown_coins = e.coins
	if absf(shown_xp-e.xp)<0.05:
		shown_xp = e.xp
	var progress := Rules.progress(int(round(shown_xp)),scene.service.economy_config)
	money.text = tr("Moedas: %d")%int(round(shown_coins))
	level_label.text = tr("Nv %d · %d/%d XP")%[progress.level,int(progress.current),int(progress.required)] if not progress.max_level else tr("Nv %d · máximo DEV")%int(progress.level)
	xp_bar.value = progress.ratio*100
	if int(e.level)>last_level:
		var names: Array = []
		for id in e.unlocks:
			if scene.service.economy_config.crops[id].unlock_level>last_level:
				names.append(tr(scene.service.catalog.entries[id].name))
		note = tr("Nível %d! ")%int(e.level)+", ".join(names)
		burst(tr("Nível %d!")%int(e.level))
		scene.audio.play("level_up")
		last_level = int(e.level)
	notice.text = note
	notice.tooltip_text = note

func burst(text: String) -> void:
	# Original authored UI texture accent + text, never blocks input.
	if is_instance_valid(toast_tween):
		toast_tween.kill()
	if is_instance_valid(toast):
		toast.queue_free()
	var label: Label = scene.kit.label(text,Rect2(scene.logical.x/2-240,scene.logical.y/2-80,480,90),38,scene.kit.PAPER)
	toast = label
	label.add_theme_color_override("font_shadow_color",scene.kit.INK)
	label.add_theme_constant_override("shadow_offset_x",2)
	label.add_theme_constant_override("shadow_offset_y",2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var tween: Tween = scene.create_tween()
	toast_tween = tween
	if scene.world.motion:
		tween.tween_property(label,"position:y",label.position.y-50,0.4)
		tween.parallel().tween_property(label,"modulate:a",0.0,1.1)
	else:
		tween.tween_interval(1.1)
	tween.tween_callback(label.queue_free)

func on_harvest(action: String) -> void:
	if action=="harvest":
		note = tr("Colheita guardada · XP recebida")
		burst(tr("+ XP · produto guardado"))

func shell(title: String) -> VBoxContainer:
	scene.cancel_input()
	scene.close_studio()
	var panel := PanelContainer.new()
	var width: float = minf(948,scene.logical.x-48)
	var height: float = minf(1400 if scene.portrait else 860,scene.logical.y-48)
	panel.position = (scene.logical-Vector2(width,height))/2
	panel.size = Vector2(width,height)
	var skin: StyleBoxTexture = scene.kit.box(Rect2(1080,64,435,418))
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		skin.set_content_margin(side,64)
	panel.add_theme_stylebox_override("panel",skin)
	scene.hud.add_child(panel)
	scene.panel = panel
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	panel.add_child(column)
	var heading := Label.new()
	heading.text = tr(title)
	heading.add_theme_color_override("font_color",scene.kit.INK)
	heading.add_theme_font_size_override("font_size",32)
	column.add_child(heading)
	var summary := Label.new()
	summary.text = tr("Saldo %d · nível %d · preços DEV")%[int(scene.service.state.economy.coins),int(scene.service.state.economy.level)]
	summary.add_theme_color_override("font_color",scene.kit.INK)
	summary.add_theme_font_size_override("font_size",24)
	column.add_child(summary)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",14)
	scroll.add_child(body)
	var feedback := Label.new()
	feedback.text = note
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color",scene.kit.INK)
	feedback.add_theme_font_size_override("font_size",24)
	column.add_child(feedback)
	button(column,"Voltar à fazenda",scene.close_studio)
	return body

func button(parent: Control, text: String, action: Callable, disabled: bool = false) -> Button:
	var b: Button = scene.kit.button(text,Rect2(0,0,200,100),action,false,parent)
	b.custom_minimum_size = Vector2(0,132 if scene.portrait else 64)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.disabled = disabled
	b.add_theme_color_override("font_disabled_color",scene.kit.INK)
	return b

func label(parent: Control, text: String) -> void:
	var l := Label.new()
	l.text = tr(text)
	l.add_theme_color_override("font_color",scene.kit.INK)
	l.add_theme_font_size_override("font_size",26)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)

func amount(parent: Control, value: int, maximum: int, action: Callable) -> SpinBox:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var spinner := SpinBox.new()
	spinner.min_value = 1
	spinner.max_value = maxi(1,maximum)
	spinner.value = value
	spinner.editable = maximum>0
	spinner.custom_minimum_size = Vector2(240,132 if scene.portrait else 64)
	spinner.add_theme_font_size_override("font_size",32)
	spinner.get_line_edit().add_theme_font_size_override("font_size",32)
	spinner.get_line_edit().add_theme_color_override("font_color",scene.kit.INK)
	var paper := StyleBoxFlat.new()
	paper.bg_color = scene.kit.PAPER
	paper.border_color = scene.kit.INK
	paper.set_border_width_all(2)
	spinner.get_line_edit().add_theme_stylebox_override("normal",paper)
	spinner.get_line_edit().add_theme_stylebox_override("focus",paper)
	spinner.value_changed.connect(action)
	var minus := button(row,"−",func() -> void: spinner.value -= 1,maximum<=0)
	minus.custom_minimum_size.x = 100
	row.add_child(spinner)
	var plus := button(row,"+",func() -> void: spinner.value += 1,maximum<=0)
	plus.custom_minimum_size.x = 100
	return spinner

func open_shop() -> void:
	if scene.service.state.is_empty():
		scene.open_studio()
		return
	mode = "shop"
	var body := shell("Loja de sementes")
	label(body,"Quantidade por compra (1–999)")
	amount(body,buy_quantity,999,func(value: float) -> void: buy_quantity = int(value); open_shop())
	for id in scene.service.catalog.ids:
		var crop: Dictionary = scene.service.catalog.entries[id]
		var rule: Dictionary = scene.service.economy_config.crops[id]
		var locked: bool = id not in scene.service.state.economy.unlocks
		label(body,"%s · %d moedas/un · %d s\n%d sementes na bolsa · %d na loja"%[tr(crop.name),int(rule.seed_price),int(crop.growth_seconds),int(scene.service.state.inventory.seeds.get(id,0)),int(scene.service.state.economy.shop_stock[id])])
		button(body,tr("Nível %d necessário")%int(rule.unlock_level) if locked else tr("Comprar %d · %d moedas")%[buy_quantity,buy_quantity*int(rule.seed_price)],buy.bind(id),locked or scene.service.state.economy.shop_stock[id]<buy_quantity)

func buy(id: String) -> void:
	transact({"type":"buy_seeds","crop_id":id,"quantity":buy_quantity})
	open_shop()

func open_inventory() -> void:
	if scene.service.state.is_empty():
		scene.open_studio()
		return
	mode = "inventory"
	var body := shell("Inventário · guardar ou vender")
	label(body,"A colheita fica guardada até você vender.")
	for i in range(scene.service.catalog.ids.size()):
		var id: String = scene.service.catalog.ids[i]
		var crop: Dictionary = scene.service.catalog.entries[id]
		var count: int = int(scene.service.state.inventory.products.get(id,0))
		var price: int = int(scene.service.economy_config.crops[id].sell_value)
		label(body,"%s · %d produtos · %d moedas/un"%[tr(crop.name),count,price])
		button(body,tr("Semear %s · %d sementes")%[tr(crop.name),int(scene.service.state.inventory.seeds.get(id,0))],scene.select_seed.bind(i),id not in scene.service.state.economy.unlocks or scene.service.state.inventory.seeds.get(id,0)<1)
		quantities[id] = mini(int(quantities.get(id,1)),maxi(1,count))
		var row := HBoxContainer.new()
		body.add_child(row)
		var sell := button(row,tr("Vender %d\n+%d moedas")%[int(quantities[id]),int(quantities[id])*price] if count>0 else tr("Sem produtos"),sell_one.bind(id),count<=0)
		amount(row,int(quantities[id]),mini(count,999),func(value: float) -> void: quantities[id] = int(value); sell.text = tr("Vender %d\n+%d moedas")%[int(value),int(value)*price])
		var check := CheckBox.new()
		check.text = tr("Selecionar todos os %d produtos · %d moedas")%[count,count*price]
		check.button_pressed = bool(selected.get(id,false))
		check.custom_minimum_size.y = 132 if scene.portrait else 64
		check.add_theme_font_size_override("font_size",24)
		check.add_theme_color_override("font_color",scene.kit.INK)
		for state in ["font_pressed_color","font_hover_color","font_hover_pressed_color","font_focus_color"]:
			check.add_theme_color_override(state,scene.kit.INK)
		check.toggled.connect(func(on: bool) -> void: selected[id] = on)
		body.add_child(check)
	var column: VBoxContainer = body.get_parent().get_parent()
	var sell_all := button(column,"Vender todos os produtos selecionados",sell_selected)
	column.move_child(sell_all,column.get_child_count()-2)

func sell_one(id: String) -> void:
	transact({"type":"sell_products","items":{id:int(quantities[id])}})
	open_inventory()

func sell_selected() -> void:
	var items: Dictionary = {}
	for id in selected:
		var count: int = int(scene.service.state.inventory.products.get(id,0))
		if selected[id] and count>0:
			items[id] = count
	transact({"type":"sell_products","items":items})
	open_inventory()

func transact(command: Dictionary) -> Dictionary:
	if busy:
		return {"ok":false,"error":"busy"}
	busy = true
	command.request_id = Crypto.new().generate_random_bytes(16).hex_encode()
	var result: Dictionary = scene.service.execute(command)
	busy = false
	if result.ok:
		note = tr("Compra salva · %d moedas")%int(result.coins_delta) if command.type=="buy_seeds" else tr("Venda salva · +%d moedas")%int(result.coins_delta)
		if not result.get("replayed",false):
			burst(note)
			scene.audio.play(command.type)
			if command.type=="sell_products":
				coin_flight()
	else:
		note = tr({"insufficient_coins":"Saldo insuficiente. Venda produtos ou compre menos.","crop_level_locked":"Cultura bloqueada pelo nível.","product_stock_insufficient":"Produtos insuficientes. Nenhum item foi vendido.","invalid_selection":"Selecione ao menos um produto.","shop_stock_insufficient":"Estoque da loja insuficiente.","invalid_quantity_or_crop":"Escolha uma quantidade válida (1–999)."}.get(result.error,"Operação não salva: "+result.error))
	tick(0.016)
	return result

func coin_flight() -> void:
	# Reuse original review-gated authored coin; no new asset or license promotion.
	if not scene.world.motion:
		return
	for i in range(3):
		var sprite := TextureRect.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = scene.kit.SKIN
		atlas.region = Rect2(140,600,300,310)
		sprite.texture = atlas
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.size = Vector2(40,40)
		sprite.position = scene.logical/2+Vector2(i*30-50,-40)
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		scene.hud.add_child(sprite)
		var tween: Tween = scene.create_tween()
		tween.tween_interval(i*0.07)
		tween.tween_property(sprite,"position",Vector2(80,22),0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(sprite,"modulate:a",0.0,0.55)
		tween.tween_callback(sprite.queue_free)

func open_history() -> void:
	if scene.service.state.is_empty():
		scene.open_studio()
		return
	mode = "history"
	var body := shell("Histórico econômico · DEV local")
	var rows: Array = scene.service.state.economy.ledger
	label(body,tr("%d transações persistidas · últimas 30")%rows.size())
	for i in range(rows.size()-1,maxi(-1,rows.size()-31),-1):
		var row: Dictionary = rows[i]
		label(body,"%s\n%s · %+d moedas · %d → %d\nOrigem: %s · t=%.0f\nOperação: %s"%[row.transaction_id,row.type,int(row.quantity),int(row.balance_before),int(row.balance_after),row.source,float(row.at),row.operation_id])
