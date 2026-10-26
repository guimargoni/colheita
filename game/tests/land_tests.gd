extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/land/local_land_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const State = preload("res://scripts/domain/land/land_state.gd")
const Land = preload("res://scripts/domain/land/land_rules.gd")
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

func service(time: RefCounted, storage: RefCounted = null) -> RefCounted:
	var farm := Service.new(Clock.new(time.now,1,"test.land.v4"),Base.MemoryStore.new() if storage==null else storage,func() -> float: return 1)
	var loaded: bool = farm.load_farm(farm.fixture())
	check(loaded,"Land service loads versioned fixture: "+farm.error)
	if not loaded:
		quit(1)
	return farm

func command(type: String, payload: Dictionary = {}) -> Dictionary:
	serial += 1
	var result := {"request_id":"land.test."+str(serial),"type":type}
	result.merge(payload)
	return result

func purchase(farm: RefCounted, id: String = "plot.expand.1") -> Dictionary:
	return command("unlock_plot",{"plot_id":id,"confirmed":true,"expected_revision":int(farm.state.revision),"quote_version":farm.land_config.version,"price":0})

func earn(farm: RefCounted, time: RefCounted, xp: int) -> void:
	while farm.state.economy.xp<xp:
		if farm.state.inventory.seeds.get("crop.carrot",0)<1:
			var buy: Dictionary = farm.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":1}))
			if not buy.ok:
				check(false,"Training fixture can buy seed")
				return
		var plant: Dictionary = farm.execute(command("plant",{"plot_id":"plot.home.a","crop_id":"crop.carrot"}))
		if not plant.ok:
			check(false,"Training fixture plants")
			return
		time.value += 128
		var harvested: Dictionary = farm.execute(command("harvest",{"plot_id":"plot.home.a","cycle_id":plant.cycle_id}))
		if not harvested.ok:
			check(false,"Training fixture harvests")
			return
		farm.execute(command("sell_products",{"items":{"crop.carrot":2}}))

func run() -> void:
	var time := Base.ControlledTime.new()
	var storage := Base.MemoryStore.new()
	var farm = service(time,storage)
	check(farm.state.plots.size()==8 and farm.state.land.history.is_empty(),"Four initial plus four future parcels, sample only")
	check(farm.execute(command("plant",{"plot_id":"plot.expand.1","crop_id":"crop.carrot"})).error=="plot_locked","Locked plot cannot plant")
	check(farm.execute(purchase(farm)).error=="land_level_required","Coins alone cannot bypass level")
	earn(farm,time,8)
	check(farm.land_quote("plot.expand.1").can_buy,"Eligible quote includes current requirements")
	var unconfirmed := purchase(farm)
	unconfirmed.confirmed = false
	check(farm.execute(unconfirmed).error=="land_confirmation_required","Significant spend requires explicit confirmation intent")
	var stale := purchase(farm)
	stale.expected_revision -= 1
	check(farm.execute(stale).error=="land_quote_stale","Stale quote cannot spend different state")
	var buy := purchase(farm)
	var before: int = int(farm.state.economy.coins)
	var result: Dictionary = farm.execute(buy)
	check(result.ok and not farm.state.plots["plot.expand.1"].locked,"Valid unlock")
	check(farm.state.economy.coins==before-40 and result.coins_delta==-40,"Authoritative price ignores zero UI price")
	check(farm.state.land.history.size()==1 and farm.state.economy.ledger.back().type=="unlock_plot","Purchase history and ledger committed")
	var revision: int = int(farm.state.revision)
	check(farm.execute(buy).get("replayed",false) and farm.state.revision==revision,"Duplicate operation replays without debit")
	check(farm.execute(purchase(farm)).error=="plot_already_unlocked" and farm.state.economy.coins==before-40,"New ID cannot buy same parcel twice")
	var conflicting := buy.duplicate(true)
	conflicting.plot_id = "plot.expand.2"
	check(farm.execute(conflicting).error=="request_id_conflict","Reuse ID for different land denied")
	farm.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":1}))
	var plant: Dictionary = farm.execute(command("plant",{"plot_id":"plot.expand.1","crop_id":"crop.carrot"}))
	check(plant.ok,"Newly unlocked plot accepts real farming")
	if not plant.ok:
		quit(1)
		return
	check(farm.execute(command("water",{"plot_id":"plot.expand.1","cycle_id":plant.cycle_id})).ok,"Care works on expansion")
	time.value += 128
	check(farm.execute(command("harvest",{"plot_id":"plot.expand.1","cycle_id":plant.cycle_id})).ok,"Expansion grows and harvests with XP")
	var reopened = service(time,storage)
	check(not reopened.state.plots["plot.expand.1"].locked and reopened.execute(buy).get("replayed",false),"Reopen preserves unlock/history/receipt")
	check(State.valid(farm.state,farm.catalog,farm.clock.profile,farm.items,farm.economy_config,farm.land_config),"Full schema 4 validates after farming")
	var corrupted: Dictionary = farm.state.duplicate(true)
	corrupted.plots["plot.expand.2"].locked = false
	check(not State.valid(corrupted,farm.catalog,farm.clock.profile,farm.items,farm.economy_config,farm.land_config),"Unlock without purchase history rejected")
	var invalid: Dictionary = farm.land_config.duplicate(true)
	invalid.plots[4].conditions = ["unknown"]
	check(not Land.valid_config(invalid,farm.economy_config),"Unsupported special conditions cannot silently unlock")
	invalid = farm.land_config.duplicate(true)
	invalid.plots[4].requires = "plot.expand.4"
	check(not Land.valid_config(invalid,farm.economy_config),"Future/cyclic prerequisite fails config validation")
	failure_tests()
	await disk_tests()
	await scene_tests()
	print("G1.4 land checks: %d; failures: %d"%[checks,failures])
	quit(0 if failures==0 else 1)

func failure_tests() -> void:
	var time := Base.ControlledTime.new()
	var store := Base.MemoryStore.new()
	var farm = service(time,store)
	earn(farm,time,32)
	check(farm.execute(purchase(farm,"plot.expand.2")).error=="land_prerequisite_required","Sequential prerequisite independently enforced")
	var before: Dictionary = farm.state.duplicate(true)
	var buy := purchase(farm)
	store.fail_write = true
	check(not farm.execute(buy).ok and farm.state==before,"Failed save rolls back wallet, plot, ledger, history and receipt")
	check(not farm.execute(purchase(farm)).ok,"Failed writer blocks further mutations")
	store.fail_write = false
	check(farm.load_farm(farm.fixture()) and farm.execute(buy).ok,"Recovery reload then same operation commits once")
	var candidate: Dictionary = farm.state.duplicate(true)
	candidate.economy.coins = 0 # Unit-rule fixture only, never saved.
	check(Land.unlock(candidate,farm.land_config,purchase(farm,"plot.expand.2"),time.value).error=="insufficient_coins","Insufficient balance independent of level and sequence")
	candidate.economy.coins = 90
	candidate.inventory.seeds = {}
	candidate.inventory.products = {}
	check(Land.unlock(candidate,farm.land_config,purchase(farm,"plot.expand.2"),time.value).error=="land_reinvestment_required","Land spend cannot leave no coins, seeds, products or growing crops")
	candidate.economy.coins = 92
	check(Land.unlock(candidate,farm.land_config,purchase(farm,"plot.expand.2"),time.value).ok and candidate.economy.coins==2,"Cheapest-seed reserve allows free player to restart farming")
	check(farm.execute(command("unlock_plot",{"plot_id":"missing","confirmed":true})).error=="unknown_plot","Unknown parcel")
	check(farm.execute(command("unlock_plot",{"plot_id":"plot.expand.2","actor_id":"visitor"})).error=="foreign_actor","Local owner guard")

func disk_tests() -> void:
	var time := Base.ControlledTime.new()
	var folder := ProjectSettings.globalize_path("res://../.local/g14/tests")
	DirAccess.make_dir_recursive_absolute(folder)
	var path := folder.path_join("land_"+str(OS.get_process_id())+".json")
	var farm = service(time,Store.new(path))
	earn(farm,time,8)
	var stale = service(time,Store.new(path))
	var buy := purchase(farm)
	check(farm.execute(buy).ok,"Real disk land purchase")
	check(not stale.execute(purchase(stale)).ok,"Stale writer cannot debit disk")
	var again = service(time,Store.new(path))
	check(not again.state.plots["plot.expand.1"].locked and again.execute(buy).get("replayed",false),"Disk receipt and unlock survive reopening")
	var wrong := Service.new(Clock.new(time.now,60,"wrong.profile"),Store.new(path))
	check(not wrong.load_farm(wrong.fixture()),"Wrong profile cannot reset land")
	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(path+".tmp")
	var process_path := folder.path_join("restart_"+str(OS.get_process_id())+".json").replace("\\","/")
	for phase in ["earn","unlock","replay","plant"]:
		var output: Array = []
		var code := OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/land_restart_probe.gd","--",phase,process_path],output,true)
		check(code==0,"Separate process "+phase+": "+str(output))
	DirAccess.remove_absolute(process_path)
	DirAccess.remove_absolute(process_path+".tmp")

func center(scene: Control, id: String) -> Vector2:
	var index: int = scene.demo.plot_ids.find(id)
	return scene.container.position+(scene.world.position+scene.world.plot_center(index))*scene.zoom

func pointer(viewport: SubViewport, point: Vector2, touch: bool, down: bool) -> void:
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

func scene_tests() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920),Vector2i(1280,720),Vector2i(720,1280)]:
		var time := Base.ControlledTime.new()
		var farm = service(time)
		earn(farm,time,8)
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g14/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		await process_frame
		var point := center(scene,"plot.expand.1")
		var before: int = int(farm.state.economy.coins)
		for down in [true,false]:
			pointer(viewport,point,resolution.y>resolution.x,down)
		check(scene.panel!=null and farm.state.economy.coins==before,"Mouse/touch on blocked plot opens info without debit")
		check(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(scene.panel.get_global_rect()),"Land panel fits "+str(resolution))
		scene.land_ui.open_plot("plot.expand.1",true)
		check(not scene.land_ui.confirm_purchase().ok and farm.state.economy.coins==before,"Immediate double tap cannot spend")
		while Time.get_ticks_msec()<scene.land_ui.ready_at+20:
			await process_frame
		var confirm: Button
		for button in scene.panel.find_children("*","Button",true,false):
			if button.text.begins_with("Confirmar terreno"):
				confirm = button
		check(confirm!=null and not confirm.disabled,"Prepared confirmation button becomes actionable")
		confirm.get_parent().get_parent().ensure_control_visible(confirm)
		await process_frame
		for down in [true,false]:
			pointer(viewport,confirm.get_global_rect().get_center(),resolution.y>resolution.x,down)
		check(farm.state.economy.coins==before-40,"Actual mouse/touch on explicit confirmation buys once")
		check(scene.panel==null and not farm.state.plots["plot.expand.1"].locked,"Purchase returns directly to farm")
		var index: int = scene.demo.plot_ids.find("plot.expand.1")
		check(scene.hit_at(point)==index,"Same footprint stays stable after unlock")
		if farm.state.inventory.seeds.get("crop.carrot",0)<1:
			farm.execute(command("buy_seeds",{"crop_id":"crop.carrot","quantity":1}))
		for down in [true,false]:
			pointer(viewport,point,resolution.y>resolution.x,down)
		check(not farm.state.plots["plot.expand.1"].crop_id.is_empty(),"Mouse/touch plants newly purchased terrain")
		var revision: int = int(farm.state.revision)
		scene.choose("camera")
		scene.gesture.press(center(scene,"plot.expand.2"))
		scene.gesture.move(center(scene,"plot.expand.2")+Vector2(60,0))
		scene.gesture.release(center(scene,"plot.expand.2"))
		check(farm.state.revision==revision and scene.panel==null,"Camera over blocked parcel never opens or buys")
		scene.choose("seed")
		point = center(scene,"plot.expand.2")
		scene.gesture.press(point)
		scene.gesture.move(point+Vector2(80,0))
		scene.gesture.release(point+Vector2(80,0))
		check(farm.state.revision==revision and scene.panel==null,"Drag starting on locked land never spends or plants neighbors")
		scene.gesture.press(point)
		scene.gesture.tick(0.56)
		scene.gesture.release(point)
		check(farm.state.revision==revision and scene.panel==null,"Long press inspects future land without buying")
		scene.gesture.press(point,0)
		scene.gesture.press(point+Vector2(40,0),1)
		scene.gesture.release(point+Vector2(40,0),1)
		scene.gesture.release(point,0)
		check(farm.state.revision==revision and scene.panel==null,"Pinch on locked land cannot buy")
		scene.land_ui.open_plot("plot.expand.2",true)
		scene.close_studio()
		check(not scene.land_ui.confirm_purchase().ok,"Closing panel revokes armed intent")
		viewport.queue_free()
		await process_frame
