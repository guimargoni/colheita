extends RefCounted
## Presentation adapter; authoritative fields stay behind FarmService.

signal acted(plot_id: int, action: String)
var service: RefCounted
var plots: Array[Dictionary] = []
var plot_ids: Array = []
var selected_seed: int = 0
var tool: String = "seed"
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
		plots.append({"id":id,"grid":plot.grid,"state":plot.state,"crop_id":plot.crop_id,"cycle_id":plot.cycle_id,"key":key,"remaining":plot.growth.remaining,"stage":plot.growth.stage})

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
	var action := intent if not intent.is_empty() else "harvest" if plot.state=="mature" else "plant"
	var command := {"request_id":Crypto.new().generate_random_bytes(16).hex_encode(),"type":action,"plot_id":plot.id,"crop_id":selected_id()}
	if action=="harvest":
		command.cycle_id = plot.cycle_id
	var result: Dictionary = service.execute(command)
	last_error = "" if result.ok else result.error
	refresh()
	if result.ok and not result.get("replayed",false):
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
