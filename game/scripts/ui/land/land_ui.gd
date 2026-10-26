extends RefCounted
## Explicit purchase intent, separate from direct farm gestures.
var scene: Control
var armed_id: String = ""
var operation_id: String = ""
var armed_revision: int = -1
var generation: int = 0
var ready_at: int = 0

func _init(owner_scene: Control) -> void:
	scene = owner_scene

func cancel_confirmation() -> void:
	armed_id = ""
	operation_id = ""
	armed_revision = -1
	generation += 1

func open_plot(id: String, confirm_view: bool = false) -> void:
	var quote: Dictionary = scene.service.land_quote(id)
	if not quote.ok:
		scene.status.text = tr("Terreno indisponível")
		return
	var body: VBoxContainer = scene.economy_ui.shell("Conquistar terreno" if not confirm_view else "Confirmar compra de terreno")
	var ui: RefCounted = scene.economy_ui
	ui.label(body,tr(quote.name))
	ui.label(body,tr("Preço: %d moedas · saldo: %d")%[quote.price,int(scene.service.state.economy.coins)])
	ui.label(body,tr(quote.benefit))
	ui.label(body,tr("Nível %d necessário: %s")%[quote.level,tr("atingido") if quote.level_ok else tr("ainda não atingido")])
	ui.label(body,tr("Saldo: ")+(tr("suficiente") if quote.balance_ok else tr("insuficiente · guarde moedas das vendas")))
	if not quote.requires.is_empty():
		ui.label(body,tr("Terreno anterior: ")+tr(quote.requires_name)+" · "+(tr("conquistado") if quote.sequence_ok else tr("compre primeiro")))
	ui.label(body,tr("Recursos para o próximo plantio: disponíveis.") if quote.capital_ok else tr("Sem sementes, produtos ou cultivo: reserve %d moedas após a compra para replantar.")%quote.reserve)
	if not quote.locked:
		ui.label(body,tr("Já conquistado · volte à fazenda para plantar."))
		return
	if not confirm_view:
		ui.button(body,tr("Preparar compra · %d moedas")%quote.price,open_plot.bind(id,true),not quote.can_buy or not scene.service.error.is_empty())
		return
	armed_id = id
	operation_id = Crypto.new().generate_random_bytes(16).hex_encode()
	armed_revision = int(scene.service.state.revision)
	ready_at = Time.get_ticks_msec()+350
	var token: int = generation
	ui.label(body,tr("Compra permanente com moedas comuns. O débito só ocorre ao confirmar abaixo."))
	var confirm: Button = ui.button(body,tr("Confirmar terreno · %d moedas")%quote.price,confirm_purchase,true)
	ui.button(body,"Cancelar compra",scene.close_studio)
	# A tap/double-click that opened this panel cannot also spend currency.
	arm_button(confirm,token,id,quote.can_buy)

func arm_button(button: Button, token: int, id: String, eligible: bool) -> void:
	# Monotonic time, independent of farm speed and a previous slow frame's delta.
	while generation==token and is_instance_valid(scene) and Time.get_ticks_msec()<ready_at:
		await scene.get_tree().process_frame
	if generation==token and armed_id==id and is_instance_valid(button):
		button.disabled = not eligible or not scene.service.error.is_empty()

func confirm_purchase() -> Dictionary:
	if armed_id.is_empty() or Time.get_ticks_msec()<ready_at:
		return {"ok":false,"error":"land_confirmation_not_armed"}
	var id: String = armed_id
	var result: Dictionary = scene.service.execute({"request_id":operation_id,"type":"unlock_plot","plot_id":id,"confirmed":true,"expected_revision":armed_revision,"quote_version":scene.service.land_config.version})
	if result.ok:
		scene.demo.refresh()
		scene.close_studio()
		scene.economy_ui.note = tr("Terreno conquistado · -%d moedas")%-int(result.coins_delta)
		if not result.get("replayed",false):
			scene.economy_ui.burst(tr("Mais espaço para cultivar!"))
			scene.audio.play("unlock_plot")
			var index: int = scene.demo.plot_ids.find(id)
			scene.world.feedback(index,"unlock_plot")
		scene.status.text = tr("Toque no terreno vazio para plantar.")
	else:
		var errors := {"land_reinvestment_required":"Guarde moedas para uma semente ou mantenha produtos/cultivo antes de expandir.","insufficient_coins":"Saldo insuficiente; nenhuma moeda foi gasta.","land_level_required":"Suba de nível para conquistar este terreno.","land_prerequisite_required":"Conquiste o terreno anterior primeiro.","plot_already_unlocked":"Este terreno já foi conquistado.","land_quote_stale":"A fazenda mudou. Selecione o terreno e revise a compra novamente."}
		scene.economy_ui.note = tr(errors.get(result.error,"Compra não confirmada: "+result.error))
		open_plot(id)
	return result
