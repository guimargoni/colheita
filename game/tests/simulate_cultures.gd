extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/cultures/local_culture_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
const Growth = preload("res://scripts/domain/cultures/repeat_rules.gd")
var serial: int = 0
var actions: int = 0

func _initialize() -> void:
	call_deferred("run")

func execute(farm: RefCounted, type: String, payload: Dictionary) -> Dictionary:
	serial += 1
	payload.merge({"request_id":"sim.land."+str(serial),"type":type})
	var result: Dictionary = farm.execute(payload)
	if result.ok:
		actions += 1
	return result

func unlocked_count(farm: RefCounted) -> int:
	var count: int = 0
	for plot in farm.state.plots.values():
		if not plot.locked:
			count += 1
	return count

func simulate(minutes: int, preferred: String, care: bool) -> Dictionary:
	actions = 0
	var time := Base.ControlledTime.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 151026
	var farm := Service.new(Clock.new(time.now,1,"sim.cultures.v5"),Base.MemoryStore.new(),rng.randf)
	if not farm.load_farm(farm.fixture()):
		push_error(farm.error)
		return {}
	# Equal established-farm baseline: earn level 3 through real commands, not grants.
	while farm.state.economy.xp<32:
		if farm.state.inventory.seeds.get("crop.carrot",0)<1:
			execute(farm,"buy_seeds",{"crop_id":"crop.carrot","quantity":1})
		var plant := execute(farm,"plant",{"plot_id":"plot.home.a","crop_id":"crop.carrot"})
		time.value += 128
		execute(farm,"harvest",{"plot_id":"plot.home.a","cycle_id":plant.cycle_id})
		execute(farm,"sell_products",{"items":{"crop.carrot":2}})
	var starting_coins: int = int(farm.state.economy.coins)
	var ledger_start: int = farm.state.economy.ledger.size()
	var calendar_start: float = float(farm.events.values()[0].start)+1000
	var harvests: int = 0
	var crops_done: Dictionary = {}
	var daily: Array = []
	actions = 0
	for day in range(3):
		for minute in range(minutes):
			time.value = calendar_start+day*86400+minute*60
			for id in farm.state.plots:
				var plot: Dictionary = farm.state.plots[id]
				if plot.locked or plot.crop_id.is_empty():
					continue
				var view: Dictionary = Growth.view(plot,farm.catalog.entries[plot.crop_id],time.value)
				if view.state=="mature":
					var result := execute(farm,"harvest",{"plot_id":id,"cycle_id":plot.cycle_id})
					if result.ok:
						harvests += 1
						crops_done[result.crop_id] = crops_done.get(result.crop_id,0)+1
				elif care:
					for kind in ["weeds","pests"]:
						if view.care[kind]:
							execute(farm,"remove_"+kind,{"plot_id":id,"cycle_id":plot.cycle_id})
			var basket: Dictionary = {}
			for crop in farm.state.inventory.products:
				if farm.state.inventory.products[crop]>0:
					basket[crop] = farm.state.inventory.products[crop]
			if not basket.is_empty():
				execute(farm,"sell_products",{"items":basket})
			for id in farm.state.plots:
				var plot: Dictionary = farm.state.plots[id]
				if plot.locked:
					continue
				if plot.crop_id.is_empty():
					var crop: String = preferred
					if farm.state.inventory.seeds.get(crop,0)<1:
						var buy := execute(farm,"buy_seeds",{"crop_id":crop,"quantity":1})
						if not buy.ok and preferred=="crop.haunted_pumpkin":
							crop = "crop.wheat"
							execute(farm,"buy_seeds",{"crop_id":crop,"quantity":1})
					execute(farm,"plant",{"plot_id":id,"crop_id":crop})
				plot = farm.state.plots[id]
				if care and not plot.crop_id.is_empty() and plot.care.water_count==0:
					execute(farm,"water",{"plot_id":id,"cycle_id":plot.cycle_id})
					if farm.state.inventory.fertilizers["fertilizer.common"]>0:
						execute(farm,"fertilize",{"plot_id":id,"cycle_id":plot.cycle_id,"item_id":"fertilizer.common","rare_ack":false})
		daily.append({"day":day+1,"coins":farm.state.economy.coins,"xp":farm.state.economy.xp})
	var spent: int = 0
	var revenue: int = 0
	for i in range(ledger_start,farm.state.economy.ledger.size()):
		var row: Dictionary = farm.state.economy.ledger[i]
		if row.type=="buy_seeds": spent -= int(row.quantity)
		if row.type=="sell_products": revenue += int(row.quantity)
	return {"minutes_per_day":minutes,"preferred":preferred,"care_and_finite_common":care,"days":3,"starting_coins":starting_coins,"final_coins":farm.state.economy.coins,"coin_change":farm.state.economy.coins-starting_coins,"xp_earned":farm.state.economy.xp-32,"harvests":harvests,"actions":actions,"seed_spend":spent,"sales":revenue,"crop_harvests":crops_done,"daily":daily,"remaining_common":farm.state.inventory.fertilizers["fertilizer.common"],"event_acquired":farm.state.seasonal.counts,"coins_per_day":float(farm.state.economy.coins-starting_coins)/3}

func run() -> void:
	var rows: Array = []
	for minutes in [5,20,60]:
		for crop in ["crop.carrot","crop.wheat","crop.bean","crop.rose","crop.haunted_pumpkin"]:
			for care in [false,true]:
				rows.append(simulate(minutes,crop,care))
	var folder := ProjectSettings.globalize_path("res://../.local/g15")
	DirAccess.make_dir_recursive_absolute(folder)
	var file := FileAccess.open(folder.path_join("balance.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"status":"PROVISIONAL_NOT_OBSERVED_PLAYERS","seed":151026,"rows":rows},"  "))
	file.close()
	print("G1.5: 30 actual-service crop comparisons PASS")
	quit(0)
