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
			ui.label(body,"%s · %d moedas · nível %d · %d s · %s"%[rule.name,int(rule.price),int(rule.level),int(rule.duration),rule.product_name])
			var owned: int = 0
			for producer in f.producers.values():
				if producer.kind==kind: owned += 1
			button(body,"Adquirir "+rule.name,act.bind("buy_producer",{"kind":kind}),s.economy.level<rule.level or owned>=int(rule.get("max_per_farm",1)))
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
			button(body,"%s · %d moedas"%[rule.name,int(rule.price)],place_options.bind(kind,""),s.economy.level<rule.level)
		for id in f.decorations:
			var item: Dictionary = f.decorations[id]
			button(body,"Mover %s · posição %d"%[config.decorations[item.kind].name,int(item.slot)+1],place_options.bind(item.kind,id))
			if item.kind=="fence": button(body,"Girar cerca",act.bind("rotate_decoration",{"id":id}))
	elif section=="Construções":
		for kind in config.buildings:
			var rule: Dictionary = config.buildings[kind]
			ui.label(body,"%s · etapa %d/%d"%[rule.name,int(f.buildings.get(kind,0)),int(rule.max)])
			button(body,"Construir / melhorar · %d moedas"%int(rule.price),act.bind("build",{"kind":kind}),s.economy.level<rule.level or f.buildings.get(kind,0)>=rule.max)
		ui.label(body,"Buquê: 3 rosas guardadas · precisa de ateliê. Produtos podem ser vendidos ou presenteados.")
		button(body,"Montar buquê",act.bind("craft_bouquet"))
		if f.goods.get("bouquet",0)>0: button(body,"Vender 1 buquê · +%d moedas"%int(config.bouquet.sell),act.bind("sell_goods",{"kind":"bouquet","quantity":1}))
	elif section=="Conquistas":
		for kind in config.achievements:
			button(body,config.achievements[kind].name+" · +%d XP"%int(config.achievements[kind].xp),act.bind("achievement_claim",{"kind":kind}),f.achievements.has(kind))
	elif section=="Social":
		scene.open_social()
func place_options(kind: String, id: String) -> void:
	var body: VBoxContainer = scene.economy_ui.shell("Escolher lugar · "+scene.service.features_config.decorations[kind].name)
	var slots: Array = preload("res://scripts/domain/integrated/features.gd").SLOTS
	for slot in range(slots.size()):
		var occupied: bool = false
		for item in scene.service.state.features.decorations.values():
			if item.slot==slot: occupied = true
		button(body,"Posição %d · (%d, %d)"%[slot+1,int(slots[slot][0]),int(slots[slot][1])],act.bind("buy_decoration" if id.is_empty() else "move_decoration",{"kind":kind,"id":id,"slot":slot}),occupied)


func producer_action(id: String) -> void:
	var p: Dictionary = scene.service.state.features.producers.get(id,{})
	if not p.is_empty(): act("producer_feed" if p.ready_at==0 else "producer_collect",{"id":id,"cycle":int(p.cycle)})
