extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/integrated/farm_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var serial: int = 0
var actions: int = 0
var results: Array = []
func _initialize() -> void: call_deferred("run")
func command(farm: RefCounted,type: String,args: Dictionary = {}) -> Dictionary:
	serial += 1; args.merge({"type":type,"request_id":"simulation."+str(serial)})
	var result: Dictionary = farm.execute(args)
	if result.ok: actions += 1
	return result
func run() -> void:
	for minutes in [5,20,60]:
		for strategy in ["carrot","wheat","diverse","producers"]:
			actions = 0
			var time := Base.ControlledTime.new()
			time.value = 1800000000
			var farm := Service.new(Clock.new(time.now,1,"simulate.integrated.v1"),Base.MemoryStore.new(),func() -> float: return 1)
			if not farm.load_farm(farm.fixture()): push_error(farm.error); quit(1); return
			var start: float = time.value
			for day in range(3):
				for minute in range(minutes+1):
					time.value = start+day*86400+minute*60
					var index: int = 0
					for id in farm.state.plots.keys():
						var p: Dictionary = farm.state.plots[id]
						if p.locked: continue
						if not p.crop_id.is_empty() and farm.Repeat.view(p,farm.catalog.entries[p.crop_id],time.value).state=="mature": command(farm,"harvest",{"plot_id":id,"cycle_id":p.cycle_id})
						p = farm.state.plots[id]
						if p.crop_id.is_empty():
							var crop: String = "crop.wheat" if strategy=="wheat" else ["crop.carrot","crop.bean","crop.rose","crop.apple"][index%4] if strategy=="diverse" else "crop.carrot"
							if crop not in farm.state.economy.unlocks: crop = "crop.carrot"
							if farm.state.inventory.seeds.get(crop,0)<1 and farm.state.economy.coins>=farm.economy_config.crops[crop].seed_price: command(farm,"buy_seeds",{"crop_id":crop,"quantity":1})
							if farm.state.inventory.seeds.get(crop,0)>0: command(farm,"plant",{"plot_id":id,"crop_id":crop})
						p = farm.state.plots[id]
						if not p.crop_id.is_empty() and p.care.water_count==0 and farm.Repeat.view(p,farm.catalog.entries[p.crop_id],time.value).state!="mature": command(farm,"water",{"plot_id":id,"cycle_id":p.cycle_id})
						index += 1
					for crop in farm.state.inventory.products.keys():
						var count: int = int(farm.state.inventory.products[crop])
						if count>0: command(farm,"sell_products",{"items":{crop:count}})
					if strategy=="producers":
						for kind in farm.features_config.producers:
							var owned: bool = false
							for p in farm.state.features.producers.values():
								if p.kind==kind: owned = true
							var rule: Dictionary = farm.features_config.producers[kind]
							if not owned and farm.state.economy.level>=rule.level and farm.state.economy.coins>=rule.price+24: command(farm,"buy_producer",{"kind":kind})
						for id in farm.state.features.producers.keys():
							var p: Dictionary = farm.state.features.producers[id]
							var rule: Dictionary = farm.features_config.producers[p.kind]
							if p.ready_at>0 and p.ready_at<=time.value: command(farm,"producer_collect",{"id":id,"cycle":int(p.cycle)})
							p = farm.state.features.producers[id]
							if p.ready_at==0:
								if farm.state.features.feed<rule.feed and farm.state.economy.coins>=10: command(farm,"buy_feed",{"quantity":5})
								if farm.state.features.feed>=rule.feed: command(farm,"producer_feed",{"id":id})
						for kind in farm.features_config.producers:
							var product: String = farm.features_config.producers[kind].product
							var count: int = int(farm.state.features.goods.get(product,0))
							if count>0: command(farm,"sell_goods",{"kind":product,"quantity":count})
					if farm.state.features.decorations.is_empty() and farm.state.economy.coins>=80: command(farm,"buy_decoration",{"kind":"flowerpot","slot":0})
			var store := Base.MemoryStore.new(); store.data = JSON.parse_string(JSON.stringify(farm.state))
			var reloaded := Service.new(Clock.new(time.now,1,"simulate.integrated.v1"),store)
			if not reloaded.load_farm(reloaded.fixture()): push_error("Simulation invariant: "+reloaded.error); quit(1); return
			results.append({"minutes_per_day":minutes,"strategy":strategy,"coins":int(farm.state.economy.coins),"xp":int(farm.state.economy.xp),"level":int(farm.state.economy.level),"animals":farm.state.features.producers.size(),"decorations":farm.state.features.decorations.size(),"actions":actions,"days":3})
			print("Simulation: "+str(minutes)+" min "+strategy+" PASS")
	var file := FileAccess.open("res://../.local/integrated/balance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"  ")); file.close()
	print("Integrated balance PASS: 12 fresh-start scenarios, 3 days each, invariant-checked JSON reload")
	quit()
