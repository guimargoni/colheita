extends "res://scripts/ui/economy/economy_presenter.gd"

const Land = preload("res://scripts/domain/land/land_rules.gd")

func refresh() -> void:
	super.refresh()
	for plot in plots:
		plot.short_label = Land.definition(service.land_config,plot.id).get("label","")

func describe(index: int) -> String:
	if index>=0 and index<plots.size() and plots[index].state=="locked":
		var quote: Dictionary = service.land_quote(plot_ids[index])
		return tr("Terreno bloqueado · %d moedas · nível %d · toque para ver")%[quote.price,quote.level]
	return super.describe(index)

func context(index: int) -> String:
	if index>=0 and index<plots.size() and plots[index].state=="locked":
		var quote: Dictionary = service.land_quote(plot_ids[index])
		return tr("Expansão futura\n%d moedas · nível %d\nToque para ver requisitos.\nArrasto não compra terrenos.")%[quote.price,quote.level]
	return super.context(index)
