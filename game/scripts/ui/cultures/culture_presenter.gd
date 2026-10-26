extends "res://scripts/ui/economy/economy_presenter.gd"

const Land = preload("res://scripts/domain/cultures/culture_land.gd")

func refresh() -> void:
	super.refresh()
	for plot in plots:
		plot.short_label = Land.definition(service.land_config,plot.id).get("label","")
		var source: Dictionary = service.state.plots[plot.id]
		if not source.crop_id.is_empty() and source.series.completed>0:
			plot.key = source.series.regrowth_stages[plot.stage].key

func describe(index: int) -> String:
	if index>=0 and index<plots.size() and plots[index].state=="locked":
		var quote: Dictionary = service.land_quote(plot_ids[index])
		return tr("Terreno bloqueado · %d moedas · nível %d · toque para ver")%[quote.price,quote.level]
	return super.describe(index)

func locked_context(index: int) -> String:
	if index>=0 and index<plots.size() and plots[index].state=="locked":
		var quote: Dictionary = service.land_quote(plot_ids[index])
		return tr("Expansão futura\n%d moedas · nível %d\nToque para ver requisitos.\nArrasto não compra terrenos.")%[quote.price,quote.level]
	return super.context(index)

func context(index: int) -> String:
	var text := locked_context(index)
	if index>=0 and index<plots.size() and not plots[index].crop_id.is_empty():
		text = text.replace("\nFalta","\n"+tr("Crescendo · falta"))
		var source: Dictionary = service.state.plots[plots[index].id]
		text += "\n"+tr("Colheitas restantes: %d")%int(source.series.total-source.series.completed)
		if source.series.completed>0:
			text += " · "+tr("recuperação")
	return text
