extends RefCounted
var scene: Control
var note: String = ""
var active_target: String = ""
var section: String = "Amigos"
class PublicFarm extends RefCounted:
	var state: Dictionary
	var catalog: RefCounted
	var land_config: Dictionary
	var clock: RefCounted
	func snapshot() -> Dictionary: return state.duplicate(true)
	func land_quote(_id: String) -> Dictionary: return {"price":0,"level":0}
func _init(owner_scene: Control) -> void: scene = owner_scene
func label(body: Control,text: String) -> void: scene.economy_ui.label(body,text)
func button(body: Control,text: String,call: Callable,disabled: bool = false) -> void: scene.economy_ui.button(body,text,call,disabled)
func invoke(method: String,args: Dictionary = {}) -> Dictionary:
	var result: Dictionary = scene.service.social(method,args)
	note = "Feito · "+str(result.get("action",method)) if result.ok else preload("res://scripts/ui/integrated/messages.gd").error(str(result.get("error","network_error")))
	if result.ok: scene.audio.play(str(args.get("action","button")) if method=="help" else "buy_seeds" if method in ["gift","community_claim"] else "button")
	return result
func action(method: String,args: Dictionary = {}) -> void:
	invoke(method,args); open()
func field(body: Control,placeholder: String) -> LineEdit:
	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.max_length = 128
	input.custom_minimum_size.y = 110 if scene.portrait else 64
	input.add_theme_font_size_override("font_size",25)
	body.add_child(input)
	return input
func open() -> void:
	var body: VBoxContainer = scene.economy_ui.shell("Vida social · laços e pequenas histórias")
	if not scene.service.has_method("social"):
		label(body,"Esta sessão é local independente. Para contas e visitas reais, abra JOGAR_COLHEITAFELIZ.cmd, que inicia o servidor local. Nenhum amigo é simulado aqui.")
		return
	var result: Dictionary = scene.service.social("social_state")
	if not result.ok: label(body,"Servidor indisponível: "+str(result.get("error",""))); return
	label(body,"%s · popularidade %d\nID: %s"%[result.player.name,int(result.popularity),result.player.id])
	if not note.is_empty(): label(body,note)
	var tabs := HFlowContainer.new(); body.add_child(tabs)
	for tab in ["Amigos","Convites","Atividade","Privacidade","Evento"]:
		var b: Button = scene.kit.button(tab,Rect2(0,0,150,64),select_tab.bind(tab),section==tab,tabs)
		b.custom_minimum_size = Vector2(155,80 if scene.portrait else 60)
	if section=="Convites":
		label(body,"Convites locais: copie o link para outra identidade deste servidor. O link abre uma página local válida. WhatsApp entre aparelhos exige hospedagem pública e aplicativo distribuível, ainda pendentes.")
		button(body,"Criar e copiar convite",create_invite)
		var invite := field(body,"Cole o link de convite ou seu código")
		button(body,"Usar convite",func() -> void: action("invite_redeem",{"code":invite.text.strip_edges()}))
		for row in result.invites:
			if not row.revoked: button(body,"Revogar convite …"+row.code.right(8),action.bind("invite_revoke",{"code":row.code}))
	if section=="Amigos":
		var query := field(body,"Encontrar fazendeiro pelo nome ou ID")
		button(body,"Encontrar",func() -> void: search(query.text))
		for row in result.requests:
			if row.to.id==result.player.id:
				label(body,row.from.name+" quer ser seu amigo")
				button(body,"Aceitar "+row.from.name,action.bind("friend_accept",{"target":row.from.id}))
				button(body,"Recusar",action.bind("friend_reject",{"target":row.from.id}))
			else:
				label(body,"Pedido enviado a "+row.to.name+" · aguardando consentimento")
				button(body,"Cancelar pedido",action.bind("friend_cancel",{"target":row.to.id}))
		label(body,"Amigos: %d"%result.friends.size())
		for player in result.friends:
			var card: VBoxContainer = scene.economy_ui.item_card(body,scene.kit.item_icon("Amigos"),player.name)
			button(card,"Visitar",visit.bind(player.id))
			button(card,"Bloquear",action.bind("block",{"target":player.id}))
	if section=="Privacidade":
		button(body,"Visitas: "+("amigos" if result.permissions.visits else "privadas"),action.bind("permissions",{"visits":not result.permissions.visits,"mischief":result.permissions.mischief}))
		button(body,"Travessuras: "+("permitidas" if result.permissions.mischief else "desativadas"),action.bind("permissions",{"visits":result.permissions.visits,"mischief":not result.permissions.mischief}))
		for player in result.blocks: button(body,"Desbloquear "+player.name,action.bind("unblock",{"target":player.id}))
	if section=="Evento":
		var community: Dictionary = scene.service.social("community_state")
		if community.ok:
			label(body,"%s · %d/%d contribuições"%[community.config.name,int(community.progress.total),int(community.config.goal)])
			button(body,"Contribuir 1 cenoura do depósito",action.bind("community_donate",{"quantity":1}))
			button(body,"Resgatar semente de rosa comunitária",action.bind("community_claim"))
	if section=="Atividade":
		label(body,"Histórico de sua fazenda")
		for index in range(result.activity.size()-1,maxi(-1,result.activity.size()-21),-1):
			var row: Dictionary = result.activity[index]
			label(body,"%s UTC · %s: %s · %s"%[Time.get_datetime_string_from_unix_time(int(row.at)),row.get("actor_name","Fazendeiro"),action_name(row.action),product_name(row.detail)])
func create_invite() -> void:
	var result := invoke("invite_create")
	if result.ok:
		DisplayServer.clipboard_set(result.link)
		note = "Convite copiado: "+result.link
	open()
func search(query: String) -> void:
	var result := invoke("discover",{"query":query.strip_edges()})
	var body: VBoxContainer = scene.economy_ui.shell("Encontrar amigos")
	if not result.ok: label(body,note); return
	for player in result.players:
		button(body,"Pedir amizade a "+player.name,action.bind("friend_request",{"target":player.id}))
		button(body,"Bloquear "+player.name,action.bind("block",{"target":player.id}))
	if result.players.is_empty(): label(body,"Nenhum jogador encontrado.")
	button(body,"Voltar ao social",open)
func visit(target: String) -> void:
	active_target = target
	var result := invoke("visit",{"target":target})
	var body: VBoxContainer = scene.economy_ui.shell("Visita · "+str(result.get("player",{}).get("name","fazenda")))
	if not result.ok: label(body,note); return
	var provider := PublicFarm.new()
	provider.state = {"plots":result.plots,"features":result.features,"inventory":{"seeds":{},"products":{}},"economy":{"level":result.level}}
	provider.catalog = scene.service.catalog
	provider.land_config = scene.service.land_config
	provider.clock = scene.service.clock
	var presenter := preload("res://scripts/ui/cultures/culture_presenter.gd").new(provider)
	var container := SubViewportContainer.new()
	container.custom_minimum_size = Vector2(880,500)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(880,500)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	container.add_child(viewport)
	var world := preload("res://scripts/visual/integrated/farm_view.gd").new()
	world.demo = presenter; world.configure()
	world.appearance.theme = scene.world.appearance.theme
	world.appearance.skins = scene.world.appearance.skins.duplicate(true)
	world.definition.plot_positions = presenter.plots.map(func(p: Dictionary) -> Array: return p.grid)
	world.scale = Vector2.ONE*1.22
	world.position = Vector2(440,255)
	world.motion = scene.world.motion; world.intensity = scene.world.intensity
	viewport.add_child(world)
	label(body,"Visita real ao servidor · dados privados não são mostrados. "+note)
	button(body,"Atualizar visita",visit.bind(target))
	for product in ["crop.rose","bouquet","egg","honey","milk","wool"]:
		button(body,"Presentear 1 "+product_name(product),visit_action.bind("gift",{"target":target,"product":product}))
	for id in result.plots:
		var plot: Dictionary = result.plots[id]
		if plot.crop_id.is_empty(): continue
		label(body,scene.service.catalog.entries[plot.crop_id].name+" · "+plot.state)
		for kind in ["water","remove_weeds","remove_pests"]:
			button(body,{"water":"Regar","remove_weeds":"Remover ervas","remove_pests":"Remover pragas"}[kind],visit_action.bind("help",{"target":target,"plot_id":id,"action":kind}))
		button(body,"Tentar pegar uma pequena parte",visit_action.bind("steal",{"target":target,"plot_id":id}),plot.state!="mature")
		button(body,"Travessura leve · ervas (se permitida)",visit_action.bind("mischief",{"target":target,"plot_id":id,"kind":"weeds"}))
	for id in result.features.producers:
		var p: Dictionary = result.features.producers[id]
		button(body,"Ajudar "+p.kind+" com meu alimento",visit_action.bind("animal_help",{"target":target,"id":id}),p.ready_at>0)
	button(body,"Voltar aos amigos",open)
func visit_action(method: String,args: Dictionary) -> void:
	invoke(method,args)
	visit(active_target)

func product_name(id: String) -> String:
	return {"crop.rose":"rosa","bouquet":"buquê","egg":"ovo","honey":"mel","milk":"leite","wool":"lã","water":"rega","remove_weeds":"limpeza de ervas","remove_pests":"remoção de pragas"}.get(id,"canteiro" if id.begins_with("plot.") else id)
func action_name(id: String) -> String:
	return {"help":"ajudou","gift":"presenteou","steal":"pegou uma pequena colheita","guardian_blocked":"encontrou o guardião","mischief":"fez uma travessura","animal_help":"alimentou um animal","friend_accept":"aceitou amizade","friend_request":"pediu amizade","invite_redeem":"usou um convite","community_donate":"contribuiu para o jardim","community_claim":"recebeu a recompensa"}.get(id,"atualizou uma preferência")

func select_tab(id: String) -> void:
	section = id; open()
