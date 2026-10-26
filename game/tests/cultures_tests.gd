extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/cultures/local_culture_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const Migration = preload("res://scripts/domain/cultures/save_migration.gd")
const State = preload("res://scripts/domain/cultures/culture_state.gd")
var serial: int = 0
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func service(time: RefCounted, store: RefCounted = null) -> RefCounted:
	var farm := Service.new(Clock.new(time.now,1,"local.cultures.real.v5"),Base.MemoryStore.new() if store==null else store,func() -> float: return 0)
	check(farm.load_farm(farm.fixture()),"G1.5 loads: "+farm.error)
	return farm

func command(type: String, payload: Dictionary = {}) -> Dictionary:
	serial += 1
	var result := {"request_id":"culture.test."+str(serial),"type":type}
	result.merge(payload)
	return result

func earn(farm: RefCounted, time: RefCounted, target: int = 32) -> void:
	while farm.state.economy.xp<target:
		if farm.state.inventory.seeds.get("crop.carrot",0)<1:
			farm.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":1}))
		var plant: Dictionary = farm.execute(command("plant",{"plot_id":"plot.home.a","crop_id":"crop.carrot"}))
		if not plant.ok:
			check(false,"Training fixture plants: "+str(plant))
			return
		time.value += 128
		farm.execute(command("harvest",{"plot_id":"plot.home.a","cycle_id":plant.cycle_id}))
		farm.execute(command("sell_products",{"items":{"crop.carrot":2}}))

func run() -> void:
	var time := Base.ControlledTime.new()
	var store := Base.MemoryStore.new()
	var farm = service(time,store)
	check(farm.catalog.ids.size()==6,"Six playable cultures; no bulk fictitious catalog")
	check(farm.execute(command("buy_seeds",{"crop_id":"crop.bean","quantity":1})).error=="crop_level_locked","New crop enforces level")
	earn(farm,time)
	for crop in ["crop.bean","crop.rose"]:
		check(farm.execute(command("buy_seeds",{"crop_id":crop,"quantity":1})).ok,"Buy new category "+crop)
		var seed_before: int = int(farm.state.inventory.seeds[crop])
		var plant: Dictionary = farm.execute(command("plant",{"plot_id":"plot.home.a","crop_id":crop}))
		check(plant.ok and farm.state.inventory.seeds[crop]==seed_before-1,"Plant consumes one seed "+crop)
		for leg in range(int(farm.catalog.entries[crop].harvest_count)):
			var plot: Dictionary = farm.state.plots["plot.home.a"]
			var cycle: String = plot.cycle_id
			check(farm.snapshot().plots[plot.id].growth.harvests_remaining==int(farm.catalog.entries[crop].harvest_count)-leg,"Remaining harvest indicator")
			time.value = float(plot.planted_at)+float(plot.base_duration)*0.70
			check(farm.snapshot().plots[plot.id].growth.stage==1,"Visible intermediate stage in first growth/recovery")
			if leg==0 and crop=="crop.bean":
				check(farm.execute(command("fertilize",{"plot_id":plot.id,"cycle_id":cycle,"item_id":"fertilizer.common"})).ok,"Fertilizer in first multi leg")
			var harvest := command("harvest",{"plot_id":plot.id,"cycle_id":cycle})
			time.value = float(plot.planted_at)+float(plot.base_duration)*1.07+1
			var before_xp: int = int(farm.state.economy.xp)
			var result: Dictionary = farm.execute(harvest)
			check(result.ok and result.harvest_index==leg+1,"First/second/final harvest")
			check(farm.execute(harvest).get("replayed",false) and farm.state.economy.xp==before_xp+int(farm.economy_config.crops[crop].harvest_xp),"No duplicate XP/products")
			if leg<int(farm.catalog.entries[crop].harvest_count)-1:
				check(farm.state.plots[plot.id].crop_id==crop and farm.state.plots[plot.id].cycle_id!=cycle,"Plant persists with a new leg ID")
				check(farm.state.plots[plot.id].base_duration==farm.catalog.entries[crop].regrowth_seconds,"Independent recovery duration")
				check(farm.state.plots[plot.id].care.history.is_empty() and farm.state.plots[plot.id].modifiers.is_empty(),"Care and acceleration reset per leg, not item stock")
				check(not farm.execute(command("harvest",{"plot_id":plot.id,"cycle_id":cycle})).ok,"Stale leg ID rejected")
				store.data = JSON.parse_string(JSON.stringify(store.data))
				var reopened := Service.new(Clock.new(time.now,1,"local.cultures.real.v5"),store,func() -> float: return 1)
				check(reopened.load_farm(reopened.fixture()) and reopened.state.plots[plot.id].series.completed==leg+1,"Recovery persists without RNG reroll")
				farm = reopened
				var next_cycle: String = farm.state.plots[plot.id].cycle_id
				check(farm.execute(command("water",{"plot_id":plot.id,"cycle_id":next_cycle})).ok,"Water on regrowth")
				check(farm.execute(command("fertilize",{"plot_id":plot.id,"cycle_id":next_cycle,"item_id":"fertilizer.common"})).ok,"Fertilizer affects current recovery only")
			else:
				check(farm.state.plots[plot.id].crop_id.is_empty() and farm.state.plots[plot.id].series==null,"Final harvest frees terrain")
		check(farm.state.inventory.seeds[crop]==seed_before-1,"No extra seed consumed in recoveries")
		var count: int = int(farm.state.inventory.products[crop])
		check(count==int(farm.catalog.entries[crop].yield_quantity)*int(farm.catalog.entries[crop].harvest_count),"Correct total yield")
		check(farm.execute(command("sell_products",{"items":{crop:1}})).ok and farm.state.inventory.products[crop]==count-1,"Flower/product can be partly sold or kept")
	check(State.valid(farm.state,farm.catalog,farm.clock.profile,farm.items,farm.economy_config,farm.land_config),"Complete state validates after repeats")
	season_tests()
	failure_tests()
	await migration_tests()
	await scene_tests()
	print("G1.5 culture checks: %d; failures: %d"%[checks,failures])
	quit(0 if failures==0 else 1)

func season_tests() -> void:
	var time := Base.ControlledTime.new()
	var memory := Base.MemoryStore.new()
	var farm = service(time,memory)
	earn(farm,time)
	var event: Dictionary = farm.events.values()[0]
	var buy := command("buy_seeds",{"crop_id":event.crop_id,"quantity":2})
	time.value = event.start-1
	check(farm.execute(buy).error=="season_unavailable","Before event unavailable")
	time.value = event.start
	check(farm.execute(buy).ok,"Event start inclusive")
	check(farm.execute(buy).get("replayed",false) and farm.state.seasonal.counts["event.cozy.harvest.g15.demo"]==2,"Seasonal purchase history idempotent")
	check(farm.execute(command("buy_seeds",{"crop_id":event.crop_id,"quantity":7})).error=="season_acquisition_limit","Acquisition cap is per farm, not current seed stock")
	var reopened := Service.new(Clock.new(time.now,1,"local.cultures.real.v5"),memory,func() -> float: return 1)
	check(reopened.load_farm(reopened.fixture()),"Seasonal counts survive JSON-compatible restart")
	time.value = event.end
	check(reopened.execute(command("buy_seeds",{"crop_id":event.crop_id,"quantity":1})).error=="season_unavailable","Event end exclusive")
	var plant: Dictionary = reopened.execute(command("plant",{"plot_id":"plot.home.a","crop_id":event.crop_id}))
	check(plant.ok,"Owned seasonal seed stays plantable after event")
	time.value += 100000
	check(reopened.execute(command("harvest",{"plot_id":"plot.home.a","cycle_id":plant.cycle_id})).ok,"Existing crop finishes after event/absence")
	check(reopened.state.inventory.products[event.crop_id]==2,"Seasonal products persist, not auto-sold or deleted")
	var before: Dictionary = farm.state.duplicate(true)
	time.value = event.start+60
	memory.fail_write = true
	check(not farm.execute(command("buy_seeds",{"crop_id":event.crop_id,"quantity":1})).ok and farm.state==before,"Failed seasonal purchase cannot consume cap, debit or grant seeds")
	memory.fail_write = false
	var fast_time := Base.ControlledTime.new()
	fast_time.value = event.start+100
	var fast := Service.new(Clock.new(fast_time.now,60,"local.cultures.fast60.v5"),Base.MemoryStore.new(),func() -> float: return 1)
	check(fast.load_farm(fast.fixture()),"Fast profile opens separately")
	earn(fast,fast_time)
	check(fast.execute(command("buy_seeds",{"crop_id":event.crop_id,"quantity":1})).ok,"Season uses unscaled calendar, not 60x crop timestamps")

func failure_tests() -> void:
	var time := Base.ControlledTime.new()
	var memory := Base.MemoryStore.new()
	var farm = service(time,memory)
	earn(farm,time)
	farm.execute(command("buy_seeds",{"crop_id":"crop.bean","quantity":1}))
	var plant: Dictionary = farm.execute(command("plant",{"plot_id":"plot.home.a","crop_id":"crop.bean"}))
	time.value += 10000
	var before: Dictionary = farm.state.duplicate(true)
	var harvest := command("harvest",{"plot_id":"plot.home.a","cycle_id":plant.cycle_id})
	memory.fail_write = true
	check(not farm.execute(harvest).ok and farm.state==before,"Failed first harvest cannot reset timer or grant rewards")
	memory.fail_write = false
	check(farm.load_farm(farm.fixture()) and farm.execute(harvest).ok,"Recovery commits same request once")
	check(farm.state.plots["plot.home.a"].planted_at==time.value,"Offline absence does not auto-collect or backdate recovery")

func migration_tests() -> void:
	var time := Base.ControlledTime.new()
	for schema in range(1,5):
		var path: String = ["res://scripts/services/farming/local_farm_service.gd","res://scripts/services/care/local_care_service.gd","res://scripts/services/economy/local_economy_service.gd","res://scripts/services/land/local_land_service.gd"][schema-1]
		var old = load(path).new(Clock.new(time.now,1,"local.real.v1"),Base.MemoryStore.new())
		var fixture: Dictionary = old.fixture() if schema==4 else JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
		check(old.load_farm(fixture),"Legacy schema initializes "+str(schema))
		var id: String = old.state.plots.keys()[0]
		var planted: Dictionary = old.execute(command("plant",{"plot_id":id,"crop_id":"crop.carrot"}))
		time.value += 128
		var legacy_harvest := command("harvest",{"plot_id":id,"cycle_id":planted.cycle_id})
		old.execute(legacy_harvest)
		if schema>=3:
			old.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":2}))
		old.execute(command("plant",{"plot_id":id,"crop_id":"crop.carrot"}))
		var original: Dictionary = old.state.duplicate(true)
		var farm = service(time)
		var result := Migration.convert(original,farm.clock.profile,farm.catalog,farm.policy,farm.items,farm.economy_config,farm.land_config)
		check(result.ok and old.state==original,"Copy migration leaves source unchanged schema "+str(schema))
		if not result.ok:
			continue
		farm.economy_config.initial_coins = result.state.genesis_coins
		check(State.valid(result.state,farm.catalog,farm.clock.profile,farm.items,farm.economy_config,result.state.layout),"Migrated state validates schema "+str(schema))
		check(result.state.plots.keys()==original.plots.keys() and result.state.plots[id].ready_at==original.plots[id].ready_at and result.state.inventory.seeds["crop.carrot"]==original.inventory.seeds["crop.carrot"],"IDs/layout/timers/seeds preserved")
		check(result.state.economy.coins==(original.economy.coins if schema>=3 else 0),"No coins retrospectively granted")
		check(result.state.inventory.products==original.inventory.products and result.state.economy.xp==(original.economy.xp if schema>=3 else 0),"Products and earned XP preserved without retrospective awards")
		var disk := Base.MemoryStore.new()
		disk.data = JSON.parse_string(JSON.stringify(result.state))
		var loaded := Service.new(Clock.new(time.now,1,farm.clock.profile),disk)
		check(loaded.load_farm(loaded.fixture()),"Reload migrated JSON without data loss")
		check(loaded.execute(legacy_harvest).get("replayed",false),"Legacy successful receipt remains idempotent after migration")
		check(not Migration.convert(original,"local.cultures.fast60.v5",farm.catalog,farm.policy,farm.items,farm.economy_config,farm.land_config).ok,"Clock multipliers cannot silently change during migration")
		var folder := ProjectSettings.globalize_path("res://../.local/g15/tests")
		DirAccess.make_dir_recursive_absolute(folder)
		var source_path := folder.path_join("legacy_"+str(OS.get_process_id())+"_"+str(schema)+".json")
		var target_path := source_path+".g15.json"
		var file := FileAccess.open(source_path,FileAccess.WRITE)
		file.store_string(JSON.stringify(original))
		file.close()
		var raw: String = FileAccess.get_file_as_string(source_path)
		var output: Array = []
		var code := OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/import_cultures_save.gd","--",source_path,target_path,"normal"],output,true)
		check(code==0 and FileAccess.get_file_as_string(source_path)==raw,"Real copy import preserves original bytes: "+str(output))
		var imported := Service.new(Clock.new(time.now,1,farm.clock.profile),Store.new(target_path))
		check(imported.load_farm(imported.fixture()),"Imported disk save opens in G1.5 schema "+str(schema)+": "+imported.error)
		check(imported.state.inventory.products.get("crop.carrot")==original.inventory.products.get("crop.carrot"),"Imported disk product count preserved numerically")
		var prior: String = FileAccess.get_file_as_string(target_path)
		output.clear()
		code = OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/import_cultures_save.gd","--",source_path,target_path,"normal"],output,true)
		check(code!=0 and FileAccess.get_file_as_string(target_path)==prior,"Import refuses overwrite of existing target")
		DirAccess.remove_absolute(source_path)
		DirAccess.remove_absolute(target_path)

func scene_tests() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920),Vector2i(1280,720),Vector2i(720,1280)]:
		var time := Base.ControlledTime.new()
		var farm = service(time)
		earn(farm,time)
		farm.execute(command("buy_seeds",{"crop_id":"crop.bean","quantity":1}))
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g15/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		await process_frame
		scene.select_seed(farm.catalog.ids.find("crop.bean"))
		var index: int = scene.demo.plot_ids.find("plot.home.a")
		var point: Vector2 = scene.container.position+(scene.world.position+scene.world.plot_center(index))*scene.zoom
		for down in [true,false]:
			pointer(viewport,point,down,resolution.y>resolution.x)
		time.value += 1000
		for down in [true,false]:
			pointer(viewport,point,down,resolution.y>resolution.x)
		check(scene.demo.context(index).contains("Colheitas restantes: 2") and scene.demo.context(index).contains("recuperação"),"Context identifies regrowth, remaining harvests")
		scene.economy_ui.filter_category = "flower"
		scene.economy_ui.open_shop()
		await process_frame
		check(scene.panel!=null and Rect2(Vector2.ZERO,Vector2(resolution)).encloses(scene.panel.get_global_rect()),"Filtered shop fits PC/portrait")
		scene.economy_ui.open_inventory()
		await process_frame
		check(scene.panel!=null,"Flower inventory supports manual storage/sale")
		viewport.queue_free()
		await process_frame

func pointer(viewport: SubViewport, point: Vector2, down: bool, touch: bool) -> void:
	if touch:
		var event := InputEventScreenTouch.new()
		event.position = point
		event.pressed = down
		viewport.push_input(event,true)
	else:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		viewport.push_input(event,true)
