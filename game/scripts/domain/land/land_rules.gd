extends RefCounted
const Economy = preload("res://scripts/domain/land/land_economy_rules.gd")

static func valid_config(config: Dictionary, economy: Dictionary) -> bool:
	if config.get("version")!="g14.land.v1" or not config.get("plots") is Array or config.plots.is_empty() or not config.get("footprint") is Array or config.footprint.size()!=2 or config.footprint[0]!=2 or config.footprint[1]!=2:
		return false
	for key in ["farm_id","owner_id"]:
		if not config.get(key) is String or config[key].is_empty():
			return false
	var seen: Dictionary = {}
	var cheapest: int = int(economy.max_value)
	for crop in economy.crops.values():
		if crop.unlock_level==1:
			cheapest = mini(cheapest,int(crop.seed_price))
	if not Economy.integer(config.get("minimum_reinvestment_coins"),int(economy.max_value)) or config.minimum_reinvestment_coins<cheapest:
		return false
	var positions: Dictionary = {}
	var initial: int = 0
	for row in config.plots:
		if not row is Dictionary or not row.get("id") is String or row.id.is_empty() or seen.has(row.id) or not row.get("grid") is Array or row.grid.size()!=2 or not row.get("region_id") is String or not row.get("name") is String or not row.get("label") is String or not row.get("initial") is bool:
			return false
		for coordinate in row.grid:
			if not (coordinate is int or coordinate is float) or not is_finite(coordinate) or coordinate!=int(coordinate) or int(coordinate)%2!=0:
				return false
		var key := "%d,%d"%[int(row.grid[0]),int(row.grid[1])]
		if positions.has(key) or not Economy.integer(row.get("price"),int(economy.max_value)) or not Economy.integer(row.get("level"),economy.xp_thresholds.size()) or row.level<1 or not row.get("requires") is String or not row.get("conditions") is Array or not row.conditions.is_empty():
			return false
		if not row.requires.is_empty() and not seen.has(row.requires):
			return false # Ordered acyclic prerequisites; unsupported conditions fail closed.
		if row.initial:
			initial += 1
			if row.price!=0 or row.level!=1 or not row.requires.is_empty():
				return false
		elif row.price<=0:
			return false
		seen[row.id] = true
		positions[key] = true
	return initial>0

static func fixture(config: Dictionary, economy: Dictionary) -> Dictionary:
	var plots: Array = []
	for row in config.plots:
		plots.append({"id":row.id,"grid":row.grid.duplicate(),"region_id":row.region_id,"locked":not row.initial})
	return {"farm_id":config.farm_id,"owner_id":config.owner_id,"initial_seeds":economy.initial_seeds.duplicate(true),"plots":plots}

static func definition(config: Dictionary, id: String) -> Dictionary:
	for row in config.plots:
		if row.id==id:
			return row
	return {}

static func quote(state: Dictionary, config: Dictionary, id: String) -> Dictionary:
	var row := definition(config,id)
	if row.is_empty() or not state.plots.has(id):
		return {"ok":false,"error":"unknown_plot"}
	var level_ok: bool = state.economy.level>=row.level
	var balance_ok: bool = state.economy.coins>=row.price
	var sequence_ok: bool = row.requires.is_empty() or not state.plots[row.requires].locked
	var locked: bool = state.plots[id].locked
	var productive: bool = false
	for crop in state.inventory.seeds:
		productive = productive or (crop in state.economy.unlocks and state.inventory.seeds[crop]>0)
	for count in state.inventory.products.values():
		productive = productive or count>0
	for plot in state.plots.values():
		productive = productive or (not plot.locked and not plot.crop_id.is_empty())
	var capital_ok: bool = productive or state.economy.coins-row.price>=config.minimum_reinvestment_coins
	return {"ok":true,"plot_id":id,"name":row.name,"requires_name":definition(config,row.requires).get("name",""),"price":int(row.price),"level":int(row.level),"level_ok":level_ok,"balance_ok":balance_ok,"sequence_ok":sequence_ok,"requires":row.requires,"locked":locked,"capital_ok":capital_ok,"reserve":int(config.minimum_reinvestment_coins),"can_buy":locked and level_ok and balance_ok and sequence_ok and capital_ok,"conditions":row.conditions.duplicate(),"benefit":"Mais um canteiro permanente para plantar e colher."}

static func unlock(state: Dictionary, config: Dictionary, command: Dictionary, now: float) -> Dictionary:
	var view := quote(state,config,command.plot_id)
	if not view.ok:
		return view
	if not view.locked:
		return {"ok":false,"error":"plot_already_unlocked"}
	if not view.level_ok:
		return {"ok":false,"error":"land_level_required"}
	if not view.sequence_ok:
		return {"ok":false,"error":"land_prerequisite_required"}
	if not view.balance_ok:
		return {"ok":false,"error":"insufficient_coins"}
	if not view.capital_ok:
		return {"ok":false,"error":"land_reinvestment_required"}
	if command.get("confirmed",false)!=true:
		return {"ok":false,"error":"land_confirmation_required"}
	if command.get("quote_version")!=config.version or command.get("expected_revision")!=state.revision:
		return {"ok":false,"error":"land_quote_stale"}
	var before: int = int(state.economy.coins)
	state.economy.coins -= view.price
	state.plots[command.plot_id].locked = false
	var items := {command.plot_id:1}
	Economy.ledger(state,"unlock_plot",-view.price,before,command.plot_id,command.request_id,now,items)
	var transaction_id: String = state.economy.ledger.back().transaction_id
	state.land.history.append({"plot_id":command.plot_id,"price":view.price,"level":view.level,"requires":view.requires,"at":now,"operation_id":command.request_id,"transaction_id":transaction_id})
	return {"ok":true,"action":"unlock_plot","plot_id":command.plot_id,"coins_delta":-view.price,"balance":state.economy.coins,"items":items,"transaction_id":transaction_id}

static func valid(state: Dictionary, config: Dictionary) -> bool:
	if not state.get("land") is Dictionary or state.land.get("version")!=config.version or not state.land.get("history") is Array or state.plots.size()!=config.plots.size():
		return false
	var bought: Dictionary = {}
	for record in state.land.history:
		if not record is Dictionary or not record.get("plot_id") is String or bought.has(record.plot_id):
			return false
		var row := definition(config,record.plot_id)
		if row.is_empty() or row.initial or record.get("price")!=row.price or record.get("level")!=row.level or record.get("requires")!=row.requires or not record.get("operation_id") is String or not state.receipts.has(record.operation_id):
			return false
		if not row.requires.is_empty() and not bought.has(row.requires) and not definition(config,row.requires).initial:
			return false
		var result: Dictionary = state.receipts[record.operation_id].result
		if result.get("action")!="unlock_plot" or result.get("plot_id")!=row.id or result.get("coins_delta")!=-row.price or result.get("transaction_id")!=record.get("transaction_id"):
			return false
		if not (record.get("at") is float or record.get("at") is int) or not is_finite(record.at) or record.at<0:
			return false
		bought[row.id] = true
	for row in config.plots:
		if not state.plots.has(row.id):
			return false
		var plot: Dictionary = state.plots[row.id]
		if plot.owner_id!=state.owner_id or plot.grid[0]!=row.grid[0] or plot.grid[1]!=row.grid[1] or plot.region_id!=row.region_id or plot.locked!=(not row.initial and not bought.has(row.id)) or (plot.locked and not plot.crop_id.is_empty()):
			return false
	var count: int = 0
	for ledger_row in state.economy.ledger:
		if ledger_row.type=="unlock_plot":
			count += 1
	return count==bought.size()
