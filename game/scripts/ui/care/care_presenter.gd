extends RefCounted
## Presentation adapter; authoritative fields stay behind FarmService.

signal acted(plot_id: int, action: String)
var service: RefCounted
var plots: Array[Dictionary] = []
var plot_ids: Array = []
var selected_seed: int = 0
var tool: String = "seed"
var selected_fertilizer: String = "fertilizer.common"
var rare_armed: bool = false
var last_error: String = ""

func _init(provider: RefCounted) -> void:
	service = provider
	refresh()

func refresh() -> void:
	var snapshot: Dictionary = service.snapshot()
	plots.clear()
	if snapshot.is_empty():
		return
	plot_ids = snapshot.plots.keys()
	plot_ids.sort()
	for id in plot_ids:
		var plot: Dictionary = snapshot.plots[id]
		var key := ""
		if not plot.crop_id.is_empty():
			key = service.catalog.entries[plot.crop_id].stages[plot.growth.stage].key
		plots.append({"id":id,"grid":plot.grid,"state":plot.state,"crop_id":plot.crop_id,"cycle_id":plot.cycle_id,"key":key,"remaining":plot.growth.remaining,"stage":plot.growth.stage,"care":plot.growth.care})

func selected_id() -> String:
	return service.catalog.ids[selected_seed]

func seed_summary() -> String:
	if service.state.is_empty():
		return tr("Falha ao abrir save · consulte Menu")
	return "%s · %s: %d"%[tr(service.catalog.entries[selected_id()].name),tr("sementes"),int(service.state.inventory.seeds.get(selected_id(),0))]

func act(index: int, intent: String = "") -> String:
	refresh()
	if index<0 or index>=plots.size() or tool=="camera":
		return ""
	var plot := plots[index]
	var action := intent if not intent.is_empty() else intent_for(index)
	var command := {"request_id":Crypto.new().generate_random_bytes(16).hex_encode(),"type":action,"plot_id":plot.id,"crop_id":selected_id()}
	if action!="plant":
		command.cycle_id = plot.cycle_id
	if action=="fertilize":
		command.item_id = selected_fertilizer
		command.rare_ack = rare_armed
	var result: Dictionary = service.execute(command)
	last_error = "" if result.ok else result.error
	refresh()
	if result.ok and not result.get("replayed",false):
		if action=="fertilize" and service.items[selected_fertilizer].rare:
			rare_armed = false
		acted.emit(index,result.action)
		return result.action
	return ""

func describe(index: int) -> String:
	if index<0 or index>=plots.size():
		return ""
	var plot := plots[index]
	if plot.state=="empty":
		return tr("Terra vazia · toque para plantar")+" · "+seed_summary()
	if plot.state=="locked":
		return tr("Terreno bloqueado · expansão não implementada")
	var crop: Dictionary = service.catalog.entries[plot.crop_id]
	var seconds := int(ceil(plot.remaining))
	var timer := "%02d:%02d:%02d"%[seconds/3600,(seconds/60)%60,seconds%60]
	return tr(crop.name)+" · "+(tr("Maduro · toque para colher") if plot.state=="mature" else tr("Crescendo")+" · "+timer)

func intent_for(index: int) -> String:
	if plots[index].state=="mature" and tool!="camera":
		return "harvest"
	return "plant" if tool=="seed" else tool

func context(index: int) -> String:
	if index<0 or index>=plots.size():
		return ""
	var plot: Dictionary = plots[index]
	if plot.state in ["empty","locked"]:
		return tr("Terreno vazio")+"\n"+seed_summary()+"\n"+tr("Toque para plantar") if plot.state=="empty" else tr("Terreno bloqueado")
	var seconds := int(ceil(plot.remaining))
	var timer := "%02d:%02d:%02d"%[seconds/3600,(seconds/60)%60,seconds%60]
	var care: Dictionary = plot.care
	return tr(service.catalog.entries[plot.crop_id].name)+"\n"+(tr("Pronto para colher") if plot.state=="mature" else tr("Falta")+" "+timer)+"\n"+tr("Água: ")+(tr("hidratada") if care.hydrated else tr("opcional · pode regar") if care.needs_water else tr("sem necessidade"))+"\n"+tr("Ervas: ")+(tr("remover") if care.weeds else tr("limpo"))+" · "+tr("Pragas: ")+(tr("remover") if care.pests else tr("limpo"))

func tool_summary() -> String:
	if tool=="fertilize" and not service.state.is_empty():
		return tr(service.items[selected_fertilizer].name)+" · "+str(int(service.state.inventory.fertilizers.get(selected_fertilizer,0)))+" "+tr("disponíveis")+(tr(" · desarmado") if service.items[selected_fertilizer].rare and not rare_armed else "")
	return tr({"water":"Regador selecionado","remove_weeds":"Remover ervas","remove_pests":"Remover pragas","camera":"Câmera livre"}.get(tool,seed_summary()))

func error_text() -> String:
	return tr({"water_not_needed":"A planta já está hidratada ou madura.","water_cooldown":"Aguarde um pouco antes de regar novamente.","water_use_limit":"Limite de regas deste cultivo atingido.","nuisance_not_present":"Não há esse incômodo neste canteiro.","no_crop":"Plante uma cultura antes de cuidar.","fertilizer_incompatible":"Este fertilizante não combina com a cultura.","no_fertilizer_stock":"Sem estoque deste fertilizante.","fertilizer_use_limit":"Limite deste fertilizante por cultivo atingido.","rare_arm_required":"Selecione e arme o Super novamente para um uso.","acceleration_limit":"Limite de aceleração: nenhum item foi gasto.","social_not_available":"Fertilizante do Amor: disponível em um gate futuro."}.get(last_error,last_error))
