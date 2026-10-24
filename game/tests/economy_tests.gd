extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/economy/local_economy_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const Rules = preload("res://scripts/domain/economy/economy_rules.gd")
const State = preload("res://scripts/domain/economy/economy_state.gd")
var checks: int = 0
var failures: int = 0
var serial: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func fixture() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))

func service(time: RefCounted, store: RefCounted = null) -> RefCounted:
	var farm := Service.new(Clock.new(time.now,1,"test.economy.v3"),Base.MemoryStore.new() if store==null else store,func() -> float: return 1)
	check(farm.load_farm(fixture()),"Economy service loads")
	return farm

func command(type: String, payload: Dictionary = {}) -> Dictionary:
	serial += 1
	var result := {"type":type,"request_id":"economy.test."+str(serial)}
	result.merge(payload)
	return result

func crop_cycle(farm: RefCounted, time: RefCounted, crop: String = "crop.carrot", plot: String = "plot.0.0") -> Dictionary:
	var planted: Dictionary = farm.execute(command("plant",{"plot_id":plot,"crop_id":crop}))
	check(planted.ok,"Plant unlocked seed")
	time.value += float(farm.catalog.entries[crop].growth_seconds)*1.06+1
	var harvested: Dictionary = farm.execute(command("harvest",{"plot_id":plot,"cycle_id":planted.get("cycle_id","")}))
	check(harvested.ok,"Harvest stores product and XP")
	return harvested

func run() -> void:
	var time := Base.ControlledTime.new()
	var memory := Base.MemoryStore.new()
	var farm = service(time,memory)
	check(farm.state.economy.coins==40 and farm.state.economy.xp==0,"One-time data-driven bootstrap")
	check(farm.execute({"request_id":"genesis","type":"buy_seeds","crop_id":"crop.carrot","quantity":1}).error=="reserved_operation_id","Bootstrap operation ID cannot collide with command ledger")
	var buy := command("buy_seeds",{"crop_id":"crop.carrot","quantity":5,"price":0,"coins":999999})
	var purchased: Dictionary = farm.execute(buy)
	check(purchased.ok and farm.state.economy.coins==30 and farm.state.inventory.seeds["crop.carrot"]==9,"Buy multiple; ignore client prices/grants")
	var revision: int = int(farm.state.revision)
	check(farm.execute(buy).get("replayed",false) and farm.state.revision==revision,"Duplicate buy does not consume or credit twice")
	buy.quantity = 1
	check(farm.execute(buy).error=="request_id_conflict","Operation ID cannot change quantity")
	check(farm.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":100})).error=="insufficient_coins","No negative wallet")
	for value in [0,-1,1.5,1000,"2",INF,NAN]:
		check(not farm.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":value})).ok,"Invalid quantity rejected: "+str(value))
	check(farm.execute(command("buy_seeds",{"crop_id":"crop.wheat","quantity":1})).error=="crop_level_locked","Locked shop crop")
	check(farm.execute(command("plant",{"plot_id":"plot.0.0","crop_id":"crop.wheat"})).error=="crop_level_locked","Plant also enforces unlock")
	check(not farm.execute(command("sell_products",{"items":{"crop.carrot":1}})).ok,"Cannot sell absent product")
	var harvested := crop_cycle(farm,time)
	check(harvested.xp==1 and farm.state.economy.xp==1 and farm.state.inventory.products["crop.carrot"]==2 and farm.state.economy.coins==30,"No automatic sale; XP harvest only")
	var harvest_id: String = "economy.test."+str(serial)
	var receipt: Dictionary = farm.state.receipts[harvest_id]
	check(receipt.result.xp==1,"XP included in atomic harvest receipt")
	var sold := command("sell_products",{"items":{"crop.carrot":1},"sell_value":999})
	check(farm.execute(sold).ok and farm.state.economy.coins==33 and farm.state.inventory.products["crop.carrot"]==1,"Unit sale recomputes value")
	check(farm.execute(sold).get("replayed",false) and farm.state.economy.coins==33,"Duplicate sale no payout twice")
	check(not farm.execute(command("sell_products",{"items":{"crop.carrot":2}})).ok,"Insufficient products fail without partial change")
	check(not farm.execute(command("sell_products",{"items":{"crop.carrot":1,"missing":2}})).ok and farm.state.inventory.products["crop.carrot"]==1,"Mixed invalid sale atomic rollback")
	check(farm.execute(command("sell_products",{"items":{"crop.carrot":1}})).ok,"Quantity sale")
	check(farm.state.economy.coins==36,"Net profit: 2*3-2 = 4 per carrot seed, values data driven")
	for i in range(7):
		crop_cycle(farm,time)
	check(farm.state.economy.level==2 and farm.state.economy.xp==8 and "crop.strawberry" in farm.state.economy.unlocks,"Exact threshold auto levels and unlocks")
	check(farm.execute(command("buy_seeds",{"crop_id":"crop.strawberry","quantity":1})).ok,"Unlocked crop now purchasable")
	crop_cycle(farm,time,"crop.strawberry")
	var batch := command("sell_products",{"items":{"crop.carrot":14,"crop.strawberry":3}})
	var balance: int = int(farm.state.economy.coins)
	check(farm.execute(batch).ok and farm.state.economy.coins==balance+57,"Sell all selected crops together")
	check(farm.state.inventory.products["crop.carrot"]==0 and farm.state.inventory.products["crop.strawberry"]==0,"All selected inventory debited atomically")
	var copied := batch.duplicate(true)
	copied.items = {"crop.strawberry":3,"crop.carrot":14}
	check(farm.execute(copied).get("replayed",false),"Canonical basket fingerprint ignores dictionary order")
	var reopened = service(time,memory)
	check(reopened.state==farm.state,"Restart preserves wallet/XP/level/unlocks/stock/ledger")
	check(reopened.execute(batch).get("replayed",false),"Sale receipt survives restart")
	check(reopened.state.economy.ledger.size()==farm.state.economy.ledger.size(),"Restart never grants coins/restocks")
	var untouched: Dictionary = farm.state.duplicate(true)
	memory.fail_write = true
	check(not farm.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":1})).ok and farm.state==untouched,"Write failure rolls back coins, seed, stock, ledger and receipt")
	check(not farm.execute(command("sell_products",{"items":{"crop.carrot":1}})).ok,"Failed writer blocks new mutations")
	memory.fail_write = false
	check(farm.load_farm(fixture()) and farm.state==untouched,"Explicit reopen recovers committed state only")
	check(Rules.valid(farm.state,farm.economy_config),"Ledger conserves wallet")
	var invalid: Dictionary = farm.state.duplicate(true)
	invalid.economy.coins += 1
	check(not State.valid(invalid,farm.catalog,farm.clock.profile,farm.items,farm.economy_config),"Inconsistent ledger rejected on load")
	for xp in [0,7,8,31,32,79,80,179,180,359,360,1000]:
		var p := Rules.progress(xp,farm.economy_config)
		check(p.level>=1 and p.ratio>=0 and p.ratio<=1,"XP boundary "+str(xp))
	var config: Dictionary = farm.economy_config.duplicate(true)
	config.xp_thresholds = [0,8,8]
	check(not Rules.valid_config(config,farm.catalog),"Malformed curve fails closed")
	critical_tests()
	await disk_tests(time)
	await scene_tests()
	print("G1.3 economy checks: %d; failures: %d"%[checks,failures])
	quit(0 if failures==0 else 1)

func critical_tests() -> void:
	var time := Base.ControlledTime.new()
	var memory := Base.MemoryStore.new()
	var farm = service(time,memory)
	var planted: Dictionary = farm.execute(command("plant",{"plot_id":"plot.0.0","crop_id":"crop.carrot"}))
	time.value += 128
	var harvest := command("harvest",{"plot_id":"plot.0.0","cycle_id":planted.cycle_id})
	var before: Dictionary = farm.state.duplicate(true)
	memory.fail_write = true
	check(not farm.execute(harvest).ok and farm.state==before,"Failed harvest cannot grant XP or product, clear plot or save receipt")
	memory.fail_write = false
	check(farm.load_farm(fixture()) and farm.execute(harvest).ok,"Harvest retry after storage recovery grants once")
	var again = service(time,memory)
	check(again.execute(harvest).get("replayed",false) and again.state.economy.xp==1,"Harvest XP replay safe across restart")
	var stale_cycle := command("harvest",{"plot_id":"plot.0.0","cycle_id":planted.cycle_id})
	check(not again.execute(stale_cycle).ok and again.state.economy.xp==1,"New request cannot collect XP from completed cycle")
	var sale := command("sell_products",{"items":{"crop.carrot":2}})
	before = again.state.duplicate(true)
	memory.fail_write = true
	check(not again.execute(sale).ok and again.state==before,"Failed sale never removes products or credits money")
	memory.fail_write = false
	check(again.load_farm(fixture()) and again.execute(sale).ok,"Retry failed sale after explicit reload")
	check(again.state.economy.xp==1,"Buying and selling grant no XP")
	var foreign := command("buy_seeds",{"crop_id":"crop.carrot","quantity":1,"actor_id":"foreign"})
	check(again.execute(foreign).error=="foreign_actor","Local owner guard still enforced; not authentication")
	again.state.economy.shop_stock["crop.carrot"] = 0
	check(again.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":1})).error=="shop_stock_insufficient","Finite shop stock enforced")
	var config: Dictionary = again.economy_config.duplicate(true)
	config.max_value = 41
	var candidate: Dictionary = before.duplicate(true)
	candidate.economy.coins = 40
	check(not Rules.trade(candidate,sale,config,time.value).ok and candidate.inventory.products["crop.carrot"]==2,"Wallet upper bound prevents overflow before item removal")
	var corrupt: Dictionary = before.duplicate(true)
	corrupt.economy.xp = 100
	corrupt.economy.level = Rules.level_for(100,again.economy_config)
	corrupt.economy.unlocks = Rules.unlocked(int(corrupt.economy.level),again.economy_config)
	check(not Rules.valid(corrupt,again.economy_config),"XP total must agree with committed harvest receipts")

func disk_tests(time: RefCounted) -> void:
	var folder := ProjectSettings.globalize_path("res://../.local/g13/tests")
	DirAccess.make_dir_recursive_absolute(folder)
	var path := folder.path_join("economy_"+str(OS.get_process_id())+".json")
	var farm = service(time,Store.new(path))
	var stale = service(time,Store.new(path))
	var buy := command("buy_seeds",{"crop_id":"crop.carrot","quantity":2})
	check(farm.execute(buy).ok,"Disk purchase commit")
	check(not stale.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":1})).ok,"Stale revision denies mutation")
	var again = service(time,Store.new(path))
	check(again.state.economy.coins==36 and again.execute(buy).get("replayed",false),"Disk reopen retains transaction and receipt")
	var bad := Service.new(Clock.new(time.now,60,"wrong.profile"),Store.new(path))
	check(not bad.load_farm(fixture()),"Profile mismatch cannot reset/grant")
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string("{invalid")
	file.close()
	check(not again.load_farm(fixture()) and FileAccess.get_file_as_string(path)=="{invalid","Corrupt save left intact; no free bootstrap")
	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(path+".tmp")
	var process_path := folder.path_join("restart_"+str(OS.get_process_id())+".json").replace("\\","/")
	for phase in ["buy","harvest","sell","replay"]:
		var output: Array = []
		var code := OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/economy_restart_probe.gd","--",phase,process_path],output,true)
		check(code==0,"Separate process "+phase+": "+str(output))
	DirAccess.remove_absolute(process_path)
	DirAccess.remove_absolute(process_path+".tmp")

func scene_tests() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920),Vector2i(1280,720),Vector2i(720,1280)]:
		var time := Base.ControlledTime.new()
		var farm = service(time)
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g13/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		await process_frame
		scene.economy_ui.open_shop()
		await process_frame
		check(scene.panel!=null and scene.hit_at(Vector2(400,400))==-1,"Shop blocks background farming")
		check(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(scene.panel.get_global_rect()),"Shop fits "+str(resolution))
		scene.economy_ui.buy_quantity = 2
		scene.economy_ui.buy("crop.carrot")
		check(farm.state.economy.coins==36,"UI purchase goes through service")
		scene.close_studio()
		scene.select_seed(0)
		var point: Vector2 = scene.container.position+(scene.world.position+scene.world.plot_center(0)-Vector2(0,8))*scene.zoom
		for down in [true,false]:
			var event := InputEventScreenTouch.new()
			event.position = point
			event.pressed = down
			viewport.push_input(event,true)
		check(farm.state.inventory.seeds["crop.carrot"]==5,"Touch plant retained in economy scene")
		time.value += 128
		scene.demo.refresh()
		for down in [true,false]:
			var event := InputEventMouseButton.new()
			event.position = point
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = down
			viewport.push_input(event,true)
		check(farm.state.economy.xp==1 and farm.state.inventory.products["crop.carrot"]==2,"Mouse harvest adds XP not coins")
		scene.economy_ui.open_inventory()
		await process_frame
		check(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(scene.panel.get_global_rect()),"Inventory scroll panel fits")
		scene.economy_ui.quantities["crop.carrot"] = 1
		scene.economy_ui.sell_one("crop.carrot")
		check(farm.state.economy.coins==39 and farm.state.inventory.products["crop.carrot"]==1,"UI sale allows keeping remaining product")
		scene.economy_ui.selected["crop.carrot"] = true
		scene.economy_ui.sell_selected()
		check(farm.state.economy.coins==42,"UI sells selected basket")
		scene.economy_ui.open_history()
		await process_frame
		check(scene.economy_ui.mode=="history","History accessible")
		viewport.queue_free()
		await process_frame
