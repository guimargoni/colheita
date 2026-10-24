extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/economy/local_economy_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
var serial: int = 0

func _initialize() -> void:
	call_deferred("run")

func execute(farm: RefCounted, type: String, payload: Dictionary) -> Dictionary:
	serial += 1
	var command := {"request_id":"sim."+str(serial),"type":type}
	command.merge(payload)
	return farm.execute(command)

func simulate(minutes: int, preferred: String, care: String) -> Dictionary:
	var time := Base.ControlledTime.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 24102026
	var farm := Service.new(Clock.new(time.now,1,"sim.economy.v3"),Base.MemoryStore.new(),rng.randf)
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
	if not farm.load_farm(fixture):
		push_error("Simulation failed to initialize")
	var harvests: int = 0
	var actions: int = 0
	var level_times: Dictionary = {"1":0}
	var daily: Array = []
	for day in range(3):
		for minute in range(minutes):
			time.value = 1000+day*86400+minute*60
			var view: Dictionary = farm.snapshot()
			for id in view.plots:
				var plot: Dictionary = farm.snapshot().plots[id]
				if plot.state=="mature":
					var result := execute(farm,"harvest",{"plot_id":id,"cycle_id":plot.cycle_id})
					if result.ok:
						harvests += 1
						actions += 1
						var level: String = str(int(farm.state.economy.level))
						if not level_times.has(level):
							level_times[level] = {"elapsed_seconds":time.value-1000,"active_minutes":day*minutes+minute}
				if farm.state.plots[id].crop_id.is_empty():
					var crop: String = preferred if preferred in farm.state.economy.unlocks else "crop.carrot"
					if farm.state.inventory.seeds.get(crop,0)<1:
						if execute(farm,"buy_seeds",{"crop_id":crop,"quantity":1}).ok:
							actions += 1
					if execute(farm,"plant",{"plot_id":id,"crop_id":crop}).ok:
						actions += 1
						var cycle: String = farm.state.plots[id].cycle_id
						if care!="none":
							if execute(farm,"water",{"plot_id":id,"cycle_id":cycle}).ok:
								actions += 1
						if care=="finite_common" and farm.state.inventory.fertilizers.get("fertilizer.common",0)>0:
							if execute(farm,"fertilize",{"plot_id":id,"cycle_id":cycle,"item_id":"fertilizer.common","rare_ack":false}).ok:
								actions += 1
				elif care!="none":
					plot = farm.snapshot().plots[id]
					for kind in ["weeds","pests"]:
						if plot.growth.care[kind]:
							if execute(farm,"remove_"+kind,{"plot_id":id,"cycle_id":plot.cycle_id}).ok:
								actions += 1
			var basket: Dictionary = {}
			for crop in farm.state.inventory.products:
				if farm.state.inventory.products[crop]>0:
					basket[crop] = farm.state.inventory.products[crop]
			if not basket.is_empty() and execute(farm,"sell_products",{"items":basket}).ok:
				actions += 1
		daily.append({"day":day+1,"coins":farm.state.economy.coins,"xp":farm.state.economy.xp,"level":farm.state.economy.level})
	return {"minutes_per_day":minutes,"preferred_crop":preferred,"care":care,"days":3,"harvests":harvests,"actions":actions,"coins":farm.state.economy.coins,"coin_change":farm.state.economy.coins-40,"xp":farm.state.economy.xp,"level":farm.state.economy.level,"level_times":level_times,"daily":daily,"remaining_common":farm.state.inventory.fertilizers["fertilizer.common"],"seeds":farm.state.inventory.seeds,"shop_stock":farm.state.economy.shop_stock}

func run() -> void:
	var rows: Array = []
	for minutes in [5,20,60]:
		for preferred in ["crop.carrot","crop.strawberry","crop.wheat"]:
			for care in ["none","care","finite_common"]:
				rows.append(simulate(minutes,preferred,care))
	var folder := ProjectSettings.globalize_path("res://../.local/g13")
	DirAccess.make_dir_recursive_absolute(folder)
	var file := FileAccess.open(folder.path_join("balance.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"status":"PROVISIONAL_SIMULATION_NOT_OBSERVED_PLAYERS","seed":24102026,"rows":rows},"  "))
	file.close()
	print("G1.3: 27 real-service economic simulations completed")
	quit(0)
