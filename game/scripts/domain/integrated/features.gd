extends RefCounted
const E = preload("res://scripts/domain/integrated/economy.gd")
const SLOTS = [[-4,0],[-4,2],[-4,4],[-4,6],[0,-4],[2,-4],[4,-4],[6,-4],[8,0],[8,2],[8,4],[8,6],[0,8],[2,8],[4,8],[6,8]]
static func fresh() -> Dictionary:
	return {"version":1,"producers":{},"goods":{},"feed":0,"decorations":{},"next_object":1,"buildings":{"house":1},"guardian":{"owned":false,"fed_until":0},"achievements":{},"collected":0}
static func valid(f: Dictionary, config: Dictionary) -> bool:
	if f.get("version")!=1 or not E.integer(f.get("feed"),1000000) or not E.integer(f.get("next_object")) or not E.integer(f.get("collected")): return false
	for key in ["producers","goods","decorations","buildings","guardian","achievements"]:
		if not f.get(key) is Dictionary: return false
	if f.producers.size()>12 or f.decorations.size()>int(config.max_objects): return false
	if not f.guardian.get("owned") is bool or not E.integer(f.guardian.get("fed_until"),9000000000000): return false
	for quantity in f.goods.values():
		if not E.integer(quantity,1000000): return false
	for p in f.producers.values():
		if not p is Dictionary or not config.producers.has(p.get("kind")) or not E.integer(p.get("cycle")) or not E.integer(p.get("ready_at"),9000000000000): return false
	var taken: Array = []
	for d in f.decorations.values():
		if not d is Dictionary or not config.decorations.has(d.get("kind")) or not E.integer(d.get("slot"),SLOTS.size()-1) or d.slot in taken: return false
		taken.append(d.slot)
	return true
static func apply(state: Dictionary, c: Dictionary, config: Dictionary, economy: Dictionary, now: float) -> Dictionary:
	var f: Dictionary = state.features
	var result := {"ok":true,"action":c.type,"xp":0}
	var cost: int = 0
	var gain: int = 0
	var id: String = c.get("id","")
	var kind: String = c.get("kind","")
	var quantity: Variant = c.get("quantity",1)
	if not E.integer(quantity,999) or quantity<1: return {"ok":false,"error":"invalid_quantity"}
	match c.type:
		"buy_producer":
			if not config.producers.has(kind): return {"ok":false,"error":"unknown_producer"}
			var rule: Dictionary = config.producers[kind]
			if state.economy.level<rule.level: return {"ok":false,"error":"level_locked"}
			if f.producers.size()>=12: return {"ok":false,"error":"capacity"}
			cost = int(rule.price)
			id = "producer."+str(int(f.next_object)); f.next_object += 1
			f.producers[id] = {"kind":kind,"cycle":0,"ready_at":0}
			result.id = id
		"buy_feed":
			cost = int(config.feed_price)*int(quantity)
			if f.feed+quantity>1000000: return {"ok":false,"error":"capacity"}
			f.feed += int(quantity)
		"producer_feed":
			if not f.producers.has(id): return {"ok":false,"error":"unknown_producer"}
			var p: Dictionary = f.producers[id]
			var rule: Dictionary = config.producers[p.kind]
			if p.ready_at>0: return {"ok":false,"error":"production_active_or_ready"}
			if f.feed<rule.feed: return {"ok":false,"error":"no_feed"}
			f.feed -= int(rule.feed); p.cycle += 1; p.ready_at = int(ceil(now+rule.duration))
		"producer_collect":
			if not f.producers.has(id): return {"ok":false,"error":"unknown_producer"}
			var p: Dictionary = f.producers[id]
			if not E.integer(c.get("cycle")) or c.cycle!=p.cycle: return {"ok":false,"error":"cycle_mismatch"}
			if p.ready_at<=0 or now<p.ready_at: return {"ok":false,"error":"not_ready"}
			var rule: Dictionary = config.producers[p.kind]
			if f.goods.get(rule.product,0)+rule.yield_quantity>1000000: return {"ok":false,"error":"capacity"}
			f.goods[rule.product] = int(f.goods.get(rule.product,0))+int(rule.yield_quantity)
			f.collected += 1; p.ready_at = 0; result.xp = int(rule.xp)
		"sell_goods":
			var price: int = int(config.bouquet.sell) if kind=="bouquet" else 0
			for rule in config.producers.values():
				if rule.product==kind: price = int(rule.sell)
			if price<=0 or f.goods.get(kind,0)<quantity: return {"ok":false,"error":"insufficient_goods"}
			f.goods[kind] -= int(quantity); gain = price*int(quantity)
		"buy_decoration":
			if not config.decorations.has(kind) or state.economy.level<config.decorations[kind].level: return {"ok":false,"error":"decoration_locked"}
			if f.decorations.size()>=int(config.max_objects): return {"ok":false,"error":"capacity"}
			var slot: Variant = c.get("slot")
			if not E.integer(slot,SLOTS.size()-1): return {"ok":false,"error":"invalid_slot"}
			for item in f.decorations.values():
				if item.slot==slot: return {"ok":false,"error":"slot_occupied"}
			cost = int(config.decorations[kind].price)
			id = "decoration."+str(int(f.next_object)); f.next_object += 1
			f.decorations[id] = {"kind":kind,"slot":int(slot)}; result.id = id
		"move_decoration":
			if not f.decorations.has(id) or not E.integer(c.get("slot"),SLOTS.size()-1): return {"ok":false,"error":"invalid_slot"}
			for key in f.decorations:
				if key!=id and f.decorations[key].slot==c.slot: return {"ok":false,"error":"slot_occupied"}
			f.decorations[id].slot = int(c.slot)
		"build":
			if not config.buildings.has(kind) or state.economy.level<config.buildings[kind].level: return {"ok":false,"error":"building_locked"}
			if f.buildings.get(kind,0)>=config.buildings[kind].max: return {"ok":false,"error":"building_complete"}
			cost = int(config.buildings[kind].price); f.buildings[kind] = int(f.buildings.get(kind,0))+1
		"craft_bouquet":
			if f.buildings.get("bouquet_workshop",0)<1: return {"ok":false,"error":"workshop_required"}
			if state.inventory.products.get("crop.rose",0)<config.bouquet.roses: return {"ok":false,"error":"roses_required"}
			state.inventory.products["crop.rose"] -= int(config.bouquet.roses)
			f.goods.bouquet = int(f.goods.get("bouquet",0))+1
		"guardian_buy":
			if f.guardian.owned or state.economy.level<config.guardian.level: return {"ok":false,"error":"guardian_locked_or_owned"}
			cost = int(config.guardian.price); f.guardian.owned = true
		"guardian_feed":
			if not f.guardian.owned or f.feed<config.guardian.feed: return {"ok":false,"error":"guardian_or_feed_required"}
			if f.guardian.fed_until>now: return {"ok":false,"error":"already_fed"}
			f.feed -= int(config.guardian.feed); f.guardian.fed_until = int(ceil(now+config.guardian.duration))
		"achievement_claim":
			if not config.achievements.has(kind) or f.achievements.has(kind): return {"ok":false,"error":"achievement_unavailable"}
			if (kind=="first_production" and f.collected<1) or (kind=="first_decoration" and f.decorations.is_empty()): return {"ok":false,"error":"achievement_incomplete"}
			f.achievements[kind] = true; result.xp = int(config.achievements[kind].xp)
		_: return {"ok":false,"error":"unknown_feature_command"}
	var before: int = int(state.economy.coins)
	if before-cost+gain<0: return {"ok":false,"error":"insufficient_coins"}
	if before-cost+gain>int(economy.max_value) or state.economy.xp+result.xp>economy.max_value: return {"ok":false,"error":"value_limit"}
	state.economy.coins = before-cost+gain
	state.economy.xp += int(result.xp)
	state.economy.level = E.level_for(int(state.economy.xp),economy)
	state.economy.unlocks = E.unlocked(int(state.economy.level),economy)
	if cost>0 or gain>0:
		result.coins_delta = gain-cost; result.items = {kind:int(quantity)}
		E.ledger(state,c.type,gain-cost,before,kind,c.request_id,now,result.items)
		result.transaction_id = state.economy.ledger.back().transaction_id
	return result
