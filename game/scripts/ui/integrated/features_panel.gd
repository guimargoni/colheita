extends RefCounted
var scene: Control
var tab: String = "Animais"
func _init(owner_scene: Control) -> void: scene = owner_scene
func button(body: Control, text: String, action: Callable, disabled: bool = false) -> void:
	scene.economy_ui.button(body,text,action,disabled)
func act(type: String, args: Dictionary = {}) -> void:
	scene.feature_action(type,args)
	open(tab)
func open(section: String = "Animais") -> void:
	tab = section
	var ui: RefCounted = scene.economy_ui
	var s: Dictionary = scene.service.state
	var f: Dictionary = s.features
	var config: Dictionary = scene.service.features_config
	var body: VBoxContainer = ui.shell("Minha fazenda · "+section)
	var tabs := HFlowContainer.new()
	body.add_child(tabs)
	for title in ["Animais","Decoração","Construções","Conquistas","Social"]:
		var b: Button = scene.kit.button(title,Rect2(0,0,190,80),open.bind(title),title==tab,tabs)
		b.custom_minimum_size = Vector2(190,100 if scene.portrait else 64)
	if section=="Animais":
		ui.label(body,"Alimento / néctar: %d · cada coleta precisa de um novo cuidado."%int(f.feed))
		button(body,"Comprar 5 alimentos · %d moedas"%(int(config.feed_price)*5),act.bind("buy_feed",{"quantity":5}))
		for kind in config.producers:
			var rule: Dictionary = config.producers[kind]
			var card: VBoxContainer = ui.item_card(body,scene.world.appearance.preview("environment."+kind),rule.name)
			ui.label(card,"%d moedas · nível %d"%[int(rule.price),int(rule.level)])
			var owned: int = 0
			for producer in f.producers.values():
				if producer.kind==kind: owned += 1
			button(card,"Adquirir "+rule.name,act.bind("buy_producer",{"kind":kind}),s.economy.level<rule.level or owned>=int(rule.get("max_per_farm",1)))
		for id in f.producers:
			var producer: Dictionary = f.producers[id]
			var rule: Dictionary = config.producers[producer.kind]
			var remaining: int = maxi(0,int(ceil(producer.ready_at-scene.service.clock.now_seconds())))
			ui.label(body,rule.name+" · "+("precisa de alimento" if producer.ready_at==0 else "produção pronta" if remaining==0 else "faltam %d s"%remaining))
			var live_label: Label = body.get_child(body.get_child_count()-1)
			button(body,"Alimentar" if producer.ready_at==0 else "Coletar "+rule.product_name,producer_action.bind(id),producer.ready_at>scene.service.clock.now_seconds())
			var live_button: Button = body.get_child(body.get_child_count()-1)
			var timer := Timer.new()
			timer.wait_time = 0.3
			body.add_child(timer)
			timer.timeout.connect(func() -> void:
				var live: Dictionary = scene.service.state.features.producers.get(id,producer)
				var left: int = maxi(0,int(ceil(live.ready_at-scene.service.clock.now_seconds())))
				live_label.text = rule.name+" · "+("precisa de alimento" if live.ready_at==0 else "produção pronta" if left==0 else "faltam %d s"%left)
				live_button.text = "Alimentar" if live.ready_at==0 else "Coletar "+rule.product_name
				live_button.disabled = live.ready_at>scene.service.clock.now_seconds()
			)
			timer.start()
		for kind in config.producers:
			var rule: Dictionary = config.producers[kind]
			var count: int = int(f.goods.get(rule.product,0))
			if count>0: button(body,"Vender 1 %s · +%d moedas (%d guardados)"%[rule.product_name,int(rule.sell),count],act.bind("sell_goods",{"kind":rule.product,"quantity":1}))
		ui.label(body,"Guardião: "+("protegendo a fazenda" if f.guardian.fed_until>scene.service.clock.now_seconds() else "precisa de alimento" if f.guardian.owned else "ainda não adquirido"))
		button(body,"Adquirir cão · %d moedas"%int(config.guardian.price),act.bind("guardian_buy"),f.guardian.owned or s.economy.level<config.guardian.level)
		button(body,"Alimentar cão",act.bind("guardian_feed"),not f.guardian.owned)
	elif section=="Decoração":
		ui.label(body,"Escolha um item e depois um lugar na borda da propriedade. Os espaços são exclusivos e persistentes.")
		for kind in config.decorations:
			var rule: Dictionary = config.decorations[kind]
			var card: VBoxContainer = ui.item_card(body,scene.world.appearance.preview("environment.well" if kind=="well" else "decor."+kind),rule.name)
			button(card,"%d moedas"%int(rule.price),place_options.bind(kind,""),s.economy.level<rule.level)
		for id in f.decorations:
			var item: Dictionary = f.decorations[id]
			button(body,"Mover %s · posição %d"%[config.decorations[item.kind].name,int(item.slot)+1],place_options.bind(item.kind,id))
			if item.kind=="fence": button(body,"Girar cerca",act.bind("rotate_decoration",{"id":id}))
	elif section=="Construções":
		for kind in config.buildings:
			var rule: Dictionary = config.buildings[kind]
			var card: VBoxContainer = ui.item_card(body,scene.world.appearance.preview("environment.house" if kind=="house" else "decor.workshop","building."+kind),rule.name)
			ui.label(card,"Etapa %d/%d"%[int(f.buildings.get(kind,0)),int(rule.max)])
			button(card,"Construir / melhorar · %d moedas"%int(rule.price),act.bind("build",{"kind":kind}),s.economy.level<rule.level or f.buildings.get(kind,0)>=rule.max)
		ui.label(body,"Buquê: 3 rosas guardadas · precisa de ateliê. Produtos podem ser vendidos ou presenteados.")
		button(body,"Montar buquê",act.bind("craft_bouquet"))
		if f.goods.get("bouquet",0)>0: button(body,"Vender 1 buquê · +%d moedas"%int(config.bouquet.sell),act.bind("sell_goods",{"kind":"bouquet","quantity":1}))
	elif section=="Conquistas":
		for kind in config.achievements:
			button(body,config.achievements[kind].name+" · +%d XP"%int(config.achievements[kind].xp),act.bind("achievement_claim",{"kind":kind}),f.achievements.has(kind))
	elif section=="Social":
		scene.open_social()
func place_options(kind: String, id: String) -> void:
	var ui: RefCounted = scene.economy_ui
	var body: VBoxContainer = scene.economy_ui.shell("Escolher lugar · "+scene.service.features_config.decorations[kind].name)
	var slots: Array = preload("res://scripts/domain/integrated/features.gd").SLOTS
	ui.label(body,"Escolha uma posição livre no mapa. A compra será salva imediatamente.")
	var board := Control.new(); board.custom_minimum_size = Vector2(820,440); body.add_child(board)
	var container := SubViewportContainer.new(); container.size = Vector2(820,440)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE; board.add_child(container)
	var viewport := SubViewport.new(); viewport.size = Vector2i(820,440); viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS; container.add_child(viewport)
	var preview := preload("res://scripts/visual/integrated/farm_view.gd").new()
	preview.demo = scene.demo; preview.definition = preview.definition.duplicate(true); preview.configure(); preview.appearance = scene.world.appearance
	preview.definition.plot_positions = scene.demo.plots.map(func(p: Dictionary) -> Array: return p.grid)
	preview.scale = Vector2.ONE*1.35; preview.position = Vector2(410,210); preview.motion = false
	viewport.add_child(preview)
	for slot in range(slots.size()):
		var occupied: bool = false
		for item in scene.service.state.features.decorations.values():
			if item.slot==slot: occupied = true
		var point: Vector2 = preview.project(Vector2(slots[slot][0],slots[slot][1]))*1.35+preview.position
		var b: Button = scene.kit.button(str(slot+1),Rect2(point-Vector2(25,25),Vector2(50,50)),act.bind("buy_decoration" if id.is_empty() else "move_decoration",{"kind":kind,"id":id,"slot":slot}),false,board)
		b.disabled = occupied; b.tooltip_text = "Ocupado" if occupied else "Colocar aqui"



func producer_action(id: String) -> void:
	var p: Dictionary = scene.service.state.features.producers.get(id,{})
	if not p.is_empty(): act("producer_feed" if p.ready_at==0 else "producer_collect",{"id":id,"cycle":int(p.cycle)})
