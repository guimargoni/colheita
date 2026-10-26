extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/land/local_land_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Growth = preload("res://scripts/domain/care/care_rules.gd")
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

func simulate(minutes: int, care: String, expand: bool) -> Dictionary:
	actions = 0
	var time := Base.ControlledTime.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 24102026
	var farm := Service.new(Clock.new(time.now,1,"sim.land.v4"),Base.MemoryStore.new(),rng.randf)
	if not farm.load_farm(farm.fixture()):
		push_error("Simulation initialization failed: "+farm.error)
		quit(1)
		return {}
	var harvests: int = 0
	var home_harvests: int = 0
	var bought: Array = []
	var daily: Array = []
	var produced: Dictionary = {}
	for day in range(3):
		for minute in range(minutes):
			time.value = 1000+day*86400+minute*60
			for id in farm.state.plots:
				var plot: Dictionary = farm.state.plots[id]
				if plot.locked or plot.crop_id.is_empty():
					continue
				var view: Dictionary = Growth.view(plot,farm.catalog.entries[plot.crop_id],time.value)
				if view.state=="mature":
					var result := execute(farm,"harvest",{"plot_id":id,"cycle_id":plot.cycle_id})
					if result.ok:
						harvests += 1
						home_harvests += 1 if id.begins_with("plot.home.") else 0
						produced[result.crop_id] = produced.get(result.crop_id,0)+result.quantity
				elif care!="none":
					for kind in ["weeds","pests"]:
						if view.care[kind]:
							execute(farm,"remove_"+kind,{"plot_id":id,"cycle_id":plot.cycle_id})
			var basket: Dictionary = {}
			for crop in farm.state.inventory.products:
				if farm.state.inventory.products[crop]>0:
					basket[crop] = farm.state.inventory.products[crop]
			if not basket.is_empty():
				execute(farm,"sell_products",{"items":basket})
			if expand:
				for row in farm.land_config.plots:
					var quote: Dictionary = farm.land_quote(row.id)
					# Simulation strategy reserves one carrot seed per open/new plot.
					if quote.can_buy and farm.state.economy.coins-quote.price>=2*(unlocked_count(farm)+1):
						var result := execute(farm,"unlock_plot",{"plot_id":row.id,"confirmed":true,"quote_version":farm.land_config.version,"expected_revision":farm.state.revision})
						if result.ok:
							bought.append({"id":row.id,"price":quote.price,"elapsed_hours":(time.value-1000)/3600,"active_minutes":day*minutes+minute,"harvests_so_far":harvests,"xp":farm.state.economy.xp,"balance_after":farm.state.economy.coins})
			for id in farm.state.plots:
				var plot: Dictionary = farm.state.plots[id]
				if plot.locked or not plot.crop_id.is_empty():
					continue
				# Short while active; a long culture in the final two minutes.
				var crop: String = "crop.carrot"
				if minutes-minute<=2:
					crop = "crop.wheat" if "crop.wheat" in farm.state.economy.unlocks else "crop.strawberry" if "crop.strawberry" in farm.state.economy.unlocks else "crop.carrot"
				if farm.state.inventory.seeds.get(crop,0)<1:
					execute(farm,"buy_seeds",{"crop_id":crop,"quantity":1})
				var planted := execute(farm,"plant",{"plot_id":id,"crop_id":crop})
				if planted.ok and care!="none":
					execute(farm,"water",{"plot_id":id,"cycle_id":planted.cycle_id})
					if care=="finite_common" and farm.state.inventory.fertilizers["fertilizer.common"]>0:
						execute(farm,"fertilize",{"plot_id":id,"cycle_id":planted.cycle_id,"item_id":"fertilizer.common","rare_ack":false})
		daily.append({"day":day+1,"coins":farm.state.economy.coins,"xp":farm.state.economy.xp,"level":farm.state.economy.level,"open_plots":unlocked_count(farm)})
	var spend: int = 0
	for row in farm.state.land.history:
		spend += int(row.price)
	return {"minutes_per_day":minutes,"care":care,"expansion_enabled":expand,"days":3,"harvests":harvests,"home_harvests":home_harvests,"home_share":float(home_harvests)/maxi(1,harvests),"actions":actions,"coins":farm.state.economy.coins,"xp":farm.state.economy.xp,"level":farm.state.economy.level,"open_plots":unlocked_count(farm),"land_spend":spend,"purchases":bought,"daily":daily,"produced":produced,"remaining_common":farm.state.inventory.fertilizers["fertilizer.common"]}

func run() -> void:
	var rows: Array = []
	for minutes in [5,20,60]:
		for care in ["none","care","finite_common"]:
			rows.append(simulate(minutes,care,true))
		rows.append(simulate(minutes,"care",false))
	var folder := ProjectSettings.globalize_path("res://../.local/g14")
	DirAccess.make_dir_recursive_absolute(folder)
	var file := FileAccess.open(folder.path_join("balance.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"status":"PROVISIONAL_SIMULATION_NOT_PLAYTEST","seed":24102026,"rows":rows},"  "))
	file.close()
	print("G1.4: 12 actual-service expansion simulations PASS")
	quit(0)
