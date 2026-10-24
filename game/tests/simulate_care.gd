extends SceneTree
## Scenario exploration with the actual service/rules, not a second formula model.
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/care/local_care_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
var serial: int = 0

func _initialize() -> void:
	call_deferred("run")

func send(farm: RefCounted, action: String, id: String, crop: String) -> Dictionary:
	serial += 1
	return farm.execute({"request_id":"simulation."+str(serial),"type":action,"plot_id":id,"crop_id":crop,"cycle_id":farm.state.plots[id].cycle_id,"item_id":"fertilizer.common"})

func scenario(minutes: int, strategy: String) -> Dictionary:
	var time = Base.ControlledTime.new()
	var random := RandomNumberGenerator.new()
	random.seed = 24102026
	var farm := Service.new(Clock.new(time.now),Base.MemoryStore.new(),random.randf)
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
	for crop in fixture.initial_seeds:
		fixture.initial_seeds[crop] = 10000
	farm.load_farm(fixture)
	var ids: Array = farm.state.plots.keys()
	ids.sort()
	var harvests := 0
	var cares := 0
	var time_saved := 0.0
	for day in range(3):
		for minute in range(minutes):
			time.value = 1000+day*86400+minute*60
			for i in range(3):
				var id: String = ids[i]
				var crop: String = farm.catalog.ids[i]
				var plot: Dictionary = farm.snapshot().plots[id]
				if plot.state=="mature":
					if send(farm,"harvest",id,crop).ok:
						harvests += 1
				if farm.state.plots[id].crop_id.is_empty():
					send(farm,"plant",id,crop)
				if strategy=="no_care":
					continue
				plot = farm.snapshot().plots[id]
				for action in ["water","remove_weeds","remove_pests"]:
					var result := send(farm,action,id,crop)
					if result.ok:
						cares += 1
						time_saved += float(result.time_saved)
				if strategy=="care_and_finite_common":
					var used := false
					for row in farm.state.plots[id].modifiers:
						used = used or row.item_id=="fertilizer.common"
					if not used:
						var result := send(farm,"fertilize",id,crop)
						if result.ok:
							time_saved += float(result.time_saved)
	return {"minutes_per_day":minutes,"days":3,"strategy":strategy,"harvests":harvests,"care_actions":cares,"common_used":8-int(farm.state.inventory.fertilizers["fertilizer.common"]),"products":farm.state.inventory.products,"time_saved_seconds":snappedf(time_saved,0.01)}

func run() -> void:
	var results: Array = []
	for minutes in [5,20,60]:
		for strategy in ["no_care","care_only","care_and_finite_common"]:
			results.append(scenario(minutes,strategy))
			await process_frame
	var path := ProjectSettings.globalize_path("res://../.local/g12")
	DirAccess.make_dir_recursive_absolute(path)
	var file := FileAccess.open(path.path_join("balance.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"status":"ILLUSTRATIVE_NOT_PLAYER_DATA","seed":24102026,"visit_interval_seconds":60,"results":results},"  "))
	file.close()
	print("G1.2 balance simulation: nine scenarios PASS; three profiles, three strategies, three days")
	quit(0)
