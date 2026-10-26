extends RefCounted
## Pure provisional economy rules. Commands supply intent, never prices or XP.
const Base = preload("res://scripts/domain/farming/farm_state.gd")

static func integer(value: Variant, maximum: int = 1000000000) -> bool:
	return Base.number(value) and value>=0 and value<=maximum and value==int(value)

static func valid_config(config: Dictionary, catalog: RefCounted) -> bool:
	if config.get("version")!="g15.economy.v1" or not integer(config.get("initial_coins")) or not integer(config.get("max_quantity")) or config.max_quantity<1 or not integer(config.get("max_value")) or config.max_value<1:
		return false
	if not config.get("xp_thresholds") is Array or config.xp_thresholds.size()<2 or config.xp_thresholds[0]!=0 or not config.get("crops") is Dictionary or not config.get("initial_seeds") is Dictionary:
		return false
	var previous: int = -1
	for threshold in config.xp_thresholds:
		if not integer(threshold) or threshold<=previous:
			return false
		previous = int(threshold)
	if config.crops.size()!=catalog.ids.size():
		return false
	for id in catalog.ids:
		if not config.crops.get(id) is Dictionary or not integer(config.initial_seeds.get(id)):
			return false
		var row: Dictionary = config.crops[id]
		for key in ["seed_price","sell_value","harvest_xp","unlock_level","shop_stock"]:
			if not integer(row.get(key)) or row[key]<1:
				return false
		if row.unlock_level>config.xp_thresholds.size():
			return false
	return config.initial_coins<=config.max_value

static func level_for(xp: int, config: Dictionary) -> int:
	var level: int = 1
	for threshold in config.xp_thresholds:
		if xp>=threshold:
			level += 1
	return level-1

static func unlocked(level: int, config: Dictionary) -> Array:
	var result: Array = []
	for id in config.crops:
		if level>=config.crops[id].unlock_level:
			result.append(id)
	result.sort()
	return result

static func progress(xp: int, config: Dictionary) -> Dictionary:
	var level := level_for(xp,config)
	var start: int = int(config.xp_thresholds[level-1])
	var end: int = int(config.xp_thresholds[level]) if level<config.xp_thresholds.size() else start
	return {"level":level,"current":xp-start,"required":end-start,"ratio":float(xp-start)/(end-start) if end>start else 1.0,"max_level":end==start}

static func initialize(state: Dictionary, config: Dictionary, now: float) -> void:
	state.schema_version = 3
	state.catalog_version = config.version
	state.inventory.seeds = config.initial_seeds.duplicate(true)
	state.economy = {"coins":int(config.initial_coins),"xp":0,"level":1,"unlocks":unlocked(1,config),"shop_stock":{},"ledger":[]}
	for id in config.crops:
		state.economy.shop_stock[id] = int(config.crops[id].shop_stock)
	ledger(state,"initial_grant",int(config.initial_coins),0,"fixture.initial","genesis",now,{})

static func ledger(state: Dictionary, type: String, delta: int, before: int, source: String, operation: String, now: float, quantities: Dictionary) -> void:
	state.economy.ledger.append({"transaction_id":state.farm_id+"/economy/"+str(state.economy.ledger.size()+1),"type":type,"currency":"coins","quantity":delta,"balance_before":before,"balance_after":before+delta,"source":source,"at":now,"operation_id":operation,"items":quantities.duplicate(true)})

static func reward(state: Dictionary, crop: String, config: Dictionary) -> Dictionary:
	var previous: int = int(state.economy.level)
	var xp: int = int(config.crops[crop].harvest_xp)
	if state.economy.xp+xp>config.max_value:
		return {"ok":false,"error":"value_limit"}
	state.economy.xp += xp
	state.economy.level = level_for(int(state.economy.xp),config)
	var before: Array = state.economy.unlocks
	state.economy.unlocks = unlocked(int(state.economy.level),config)
	return {"ok":true,"xp":xp,"level_before":previous,"level_after":state.economy.level,"unlocked":state.economy.unlocks.filter(func(id: String) -> bool: return id not in before)}

static func trade(state: Dictionary, command: Dictionary, config: Dictionary, now: float) -> Dictionary:
	var type: String = command.type
	var quantities: Dictionary = {}
	if type=="buy_seeds":
		if not config.crops.has(command.get("crop_id")) or not integer(command.get("quantity"),int(config.max_quantity)) or command.quantity<1:
			return {"ok":false,"error":"invalid_quantity_or_crop"}
		quantities[command.crop_id] = int(command.quantity)
	else:
		if not command.get("items") is Dictionary or command.items.is_empty() or command.items.size()>config.crops.size():
			return {"ok":false,"error":"invalid_selection"}
		for id in command.items:
			if not config.crops.has(id) or not integer(command.items[id],int(config.max_value)) or command.items[id]<1:
				return {"ok":false,"error":"invalid_quantity_or_crop"}
			quantities[id] = int(command.items[id])
	var total: int = 0
	for id in quantities:
		var count: int = quantities[id]
		if type=="buy_seeds":
			if id not in state.economy.unlocks:
				return {"ok":false,"error":"crop_level_locked"}
			if count>state.economy.shop_stock[id]:
				return {"ok":false,"error":"shop_stock_insufficient"}
			if state.inventory.seeds.get(id,0)+count>config.max_value:
				return {"ok":false,"error":"value_limit"}
			total += count*int(config.crops[id].seed_price)
		else:
			if count>state.inventory.products.get(id,0):
				return {"ok":false,"error":"product_stock_insufficient"}
			total += count*int(config.crops[id].sell_value)
	var before: int = int(state.economy.coins)
	var delta: int = -total if type=="buy_seeds" else total
	if before+delta<0:
		return {"ok":false,"error":"insufficient_coins"}
	if before+delta>config.max_value:
		return {"ok":false,"error":"value_limit"}
	for id in quantities:
		if type=="buy_seeds":
			state.inventory.seeds[id] = state.inventory.seeds.get(id,0)+quantities[id]
			state.economy.shop_stock[id] -= quantities[id]
		else:
			state.inventory.products[id] -= quantities[id]
	state.economy.coins = before+delta
	ledger(state,type,delta,before,type,command.request_id,now,quantities)
	return {"ok":true,"action":type,"coins_delta":delta,"balance":state.economy.coins,"items":quantities,"transaction_id":state.economy.ledger.back().transaction_id}

static func valid(state: Dictionary, config: Dictionary) -> bool:
	if not state.get("economy") is Dictionary:
		return false
	for kind in ["seeds","products"]:
		for count in state.inventory[kind].values():
			if not integer(count,int(config.max_value)):
				return false
	var e: Dictionary = state.economy
	for key in ["coins","xp","level"]:
		if not integer(e.get(key),int(config.max_value)):
			return false
	if e.level!=level_for(int(e.xp),config) or e.get("unlocks")!=unlocked(int(e.level),config) or not e.get("shop_stock") is Dictionary or not e.get("ledger") is Array or e.ledger.is_empty():
		return false
	for id in config.crops:
		if not integer(e.shop_stock.get(id),int(config.crops[id].shop_stock)):
			return false
	var balance: int = 0
	var operations: Dictionary = {}
	var xp_total: int = 0
	for receipt in state.receipts.values():
		var result: Dictionary = receipt.result
		if result.get("action")=="harvest":
			if not config.crops.has(result.get("crop_id")) or not integer(result.get("xp")):
				return false
			xp_total += int(result.xp)
	if xp_total!=e.xp:
		return false
	for i in range(e.ledger.size()):
		var row = e.ledger[i]
		if not row is Dictionary or row.get("transaction_id")!=state.farm_id+"/economy/"+str(i+1) or row.get("type") not in ["initial_grant","buy_seeds","sell_products","unlock_plot"] or row.get("currency")!="coins" or not row.get("operation_id") is String or operations.has(row.operation_id) or not row.get("source") is String or not Base.number(row.get("at")) or row.at<0 or not row.get("items") is Dictionary:
			return false
		if not Base.number(row.get("quantity")) or row.quantity!=int(row.quantity) or row.get("balance_before")!=balance or not integer(row.get("balance_after"),int(config.max_value)) or row.balance_after!=balance+row.quantity:
			return false
		if i==0:
			if row.type!="initial_grant" or row.operation_id!="genesis" or row.quantity!=config.initial_coins:
				return false
		else:
			if row.type=="initial_grant" or not state.receipts.has(row.operation_id):
				return false
			var result: Dictionary = state.receipts[row.operation_id].result
			if result.get("transaction_id")!=row.transaction_id or result.get("coins_delta")!=row.quantity or result.get("items")!=row.items or result.get("action")!=row.type:
				return false
		operations[row.operation_id] = true
		balance = int(row.balance_after)
	return balance==e.coins
