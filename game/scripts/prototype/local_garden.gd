extends RefCounted
## Session-only sandbox. No wallet, XP grants, network, save or production economy.

signal changed
signal acted(plot_id: int, action: String)

var config: Dictionary
var plots: Array[Dictionary] = []
var selected_seed: int = 0
var tool: String = "seed"
var harvest_count: int = 0
var action_count: int = 0


func _init() -> void:
	config = JSON.parse_string(FileAccess.get_file_as_string("res://data/prototype/local_garden.json"))
	reset()


func reset() -> void:
	plots.clear()
	for i in range(config.initial_states.size()):
		plots.append({"state":config.initial_states[i],"seed":i%config.seeds.size(),"elapsed":0.0})
	harvest_count = 0
	action_count = 0
	changed.emit()


func act(id: int) -> String:
	if id<0 or id>=plots.size() or tool=="camera":
		return ""
	var action := ""
	var plot := plots[id]
	if plot.state=="mature":
		plot.state = "empty"
		harvest_count += 1
		action = "harvest"
	elif plot.state=="empty" and tool=="seed":
		plot.seed = selected_seed
		plot.state = "needs_water"
		action = "plant"
	elif plot.state=="needs_water" and tool=="water":
		plot.state = "growing"
		plot.elapsed = 0.0
		action = "water"
	if not action.is_empty():
		action_count += 1
		acted.emit(id,action)
		changed.emit()
	return action


func tick(delta: float) -> void:
	var updated := false
	for plot in plots:
		if plot.state=="growing":
			plot.elapsed += maxf(0,delta)
			if plot.elapsed>=float(config.demo_growth_seconds):
				plot.state = "mature"
				updated = true
	if updated:
		changed.emit()


func describe(id: int) -> String:
	if id<0 or id>=plots.size():
		return ""
	var plot := plots[id]
	var state: String = {"empty":"Terra pronta • selecione uma semente", "mature":"Pronto! Toque para colher", "needs_water":"Com sede • use o regador", "growing":"Crescendo • ciclo de demonstração"}[plot.state]
	return "Canteiro %02d  /  %s\n%s" % [id+1, config.seeds[plot.seed].name, state]
