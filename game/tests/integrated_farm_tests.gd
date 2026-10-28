extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/integrated/farm_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var serial: int = 0
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(text)
func cmd(s: RefCounted, type: String, args: Dictionary = {}) -> Dictionary:
	serial += 1
	args.merge({"type":type,"request_id":"integrated.test."+str(serial)})
	return s.execute(args)
func run() -> void:
	var time := Base.ControlledTime.new()
	var store := Base.MemoryStore.new()
	var farm := Service.new(Clock.new(time.now,1,"integrated.local.v1"),store,func() -> float: return 1)
	check(farm.load_farm(farm.fixture()),"Integrated farm loads: "+farm.error)
	if not farm.error.is_empty(): quit(1); return
	check(farm.catalog.ids.size()==7,"Adds fruit tree")
	check(not cmd(farm,"buy_producer",{"kind":"cow"}).ok,"Producer level gate")
	while farm.state.economy.xp<160:
		if farm.state.inventory.seeds.get("crop.carrot",0)<1: cmd(farm,"buy_seeds",{"crop_id":"crop.carrot","quantity":1})
		var plant := cmd(farm,"plant",{"plot_id":"plot.home.a","crop_id":"crop.carrot"})
		time.value += 140
		check(cmd(farm,"harvest",{"plot_id":"plot.home.a","cycle_id":plant.get("cycle_id","")}).ok,"Earn progress")
		cmd(farm,"sell_products",{"items":{"crop.carrot":2}})
	check(cmd(farm,"buy_feed",{"quantity":20}).ok,"Buy finite feed")
	for kind in farm.features_config.producers:
		var buy := cmd(farm,"buy_producer",{"kind":kind})
		check(buy.ok,"Buy "+kind+": "+str(buy))
		if not buy.ok: continue
		check(cmd(farm,"producer_feed",{"id":buy.id}).ok,"Feed starts cycle")
		check(not cmd(farm,"producer_feed",{"id":buy.id}).ok,"No feeding duplicate")
		var cycle: int = int(farm.state.features.producers[buy.id].cycle)
		check(not cmd(farm,"producer_collect",{"id":buy.id,"cycle":cycle}).ok,"No early production")
		time.value += farm.features_config.producers[kind].duration
		var request := {"type":"producer_collect","request_id":"collect."+kind,"id":buy.id,"cycle":cycle}
		var result: Dictionary = farm.execute(request)
		check(result.ok,"Collect "+kind+": "+str(result))
		var unchanged := JSON.stringify(farm.state)
		check(farm.execute(request).get("replayed",false) and JSON.stringify(farm.state)==unchanged,"Producer receipt replays exactly")
		check(not cmd(farm,"producer_collect",{"id":buy.id,"cycle":cycle}).ok,"New ID cannot duplicate collection")
		check(cmd(farm,"sell_goods",{"kind":farm.features_config.producers[kind].product,"quantity":1}).ok,"Sell production")
	check(cmd(farm,"buy_decoration",{"kind":"flowerpot","slot":0}).ok,"Purchase and place decoration")
	check(not cmd(farm,"buy_decoration",{"kind":"fence","slot":0}).ok,"No overlapping decor")
	var deco: String = farm.state.features.decorations.keys()[0]
	check(cmd(farm,"move_decoration",{"id":deco,"slot":1}).ok,"Move decoration")
	check(cmd(farm,"achievement_claim",{"kind":"first_decoration"}).ok,"Claim achievement")
	check(not cmd(farm,"achievement_claim",{"kind":"first_decoration"}).ok,"No achievement duplication")
	store.data = JSON.parse_string(JSON.stringify(store.data))
	var reopened := Service.new(Clock.new(time.now,1,"integrated.local.v1"),store)
	check(reopened.load_farm(reopened.fixture()),"Feature state/ledger survives JSON restart: "+reopened.error)
	if not reopened.error.is_empty(): quit(1); return
	check(reopened.state.features.decorations[deco].slot==1,"Decoration remains placed")
	check(not cmd(reopened,"buy_feed",{"quantity":-1}).ok,"No negative feed exploit")
	expanded_mechanics()
	migration_tests()
	print("Integrated farm checks: %d; failures: %d"%[checks,failures])
	quit(1 if failures else 0)

func migration_tests() -> void:
	var time := Base.ControlledTime.new()
	for schema in range(1,6):
		var path: String = ["res://scripts/services/farming/local_farm_service.gd","res://scripts/services/care/local_care_service.gd","res://scripts/services/economy/local_economy_service.gd","res://scripts/services/land/local_land_service.gd","res://scripts/services/cultures/local_culture_service.gd"][schema-1]
		var old = load(path).new(Clock.new(time.now,1,"local.cultures.real.v5" if schema==5 else "local.real.v1"),Base.MemoryStore.new())
		var fixture: Dictionary = old.fixture() if schema>=4 else JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
		check(old.load_farm(fixture),"Initialize legacy "+str(schema))
		var id: String = old.state.plots.keys()[0]
		var planted: Dictionary = cmd(old,"plant",{"plot_id":id,"crop_id":"crop.carrot"})
		var before := JSON.stringify(old.state)
		var target := Service.new(Clock.new(time.now,1,"integrated.real.v1"),Base.MemoryStore.new())
		var result: Dictionary = preload("res://scripts/domain/integrated/save_migration.gd").convert(old.state,false,target)
		check(result.ok and JSON.stringify(old.state)==before,"Migration copies source "+str(schema))
		if not result.ok: continue
		check(result.state.plots.keys()==old.state.plots.keys() and result.state.plots[id].ready_at==old.state.plots[id].ready_at,"Migration preserves IDs/timers")
		check(result.state.economy.coins==(old.state.economy.coins if schema>=3 else 0),"No retroactive coins")
		var disk := Base.MemoryStore.new(); disk.data = JSON.parse_string(JSON.stringify(result.state))
		var loaded := Service.new(Clock.new(time.now,1,"integrated.real.v1"),disk)
		check(loaded.load_farm(loaded.fixture()),"Integrated copy reloads "+str(schema)+": "+loaded.error)
		check(loaded.execute({"type":"plant","request_id":"integrated.test."+str(serial),"plot_id":id,"crop_id":"crop.carrot"}).get("replayed",false),"Prior planting receipt remains idempotent")

func expanded_mechanics() -> void:
	var farm := preload("res://tests/integrated_sample.gd").new().create()
	var rose: Dictionary = farm.state.plots["plot.home.b"]
	check(cmd(farm,"harvest",{"plot_id":rose.id,"cycle_id":rose.cycle_id}).ok,"Harvest flowers for actual recipe")
	check(cmd(farm,"craft_bouquet").ok and farm.state.features.goods.get("bouquet",0)==1,"Workshop consumes roses and produces bouquet")
	check(farm.state.inventory.products["crop.rose"]==0,"No free roses after crafting")
	check(not cmd(farm,"craft_bouquet").ok,"Cannot craft without ingredients")
	check(cmd(farm,"sell_goods",{"kind":"bouquet","quantity":1}).ok,"Bouquet can be sold")
	check(not cmd(farm,"sell_goods",{"kind":"bouquet","quantity":1}).ok,"Cannot oversell bouquet")
	var apple: Dictionary = farm.state.plots["plot.home.c"]
	check(cmd(farm,"harvest",{"plot_id":apple.id,"cycle_id":apple.cycle_id}).ok,"Fruit tree harvest works")
	check(farm.state.plots[apple.id].series.completed==1 and not farm.state.plots[apple.id].crop_id.is_empty(),"Fruit tree remains for next season")
	var fence := cmd(farm,"buy_decoration",{"kind":"fence","slot":1})
	check(fence.ok and cmd(farm,"rotate_decoration",{"id":fence.id}).ok,"Bought fence rotates using its authored opposite view")
	check(farm.state.features.decorations[fence.id].orientation==1,"Fence direction persisted in state")
	var before := JSON.stringify(farm.state)
	check(not cmd(farm,"buy_producer",{"kind":"chicken"}).ok and JSON.stringify(farm.state)==before,"Configured animal capacity never debits a duplicate purchase")
	farm.store.fail_write = true
	check(not cmd(farm,"buy_feed",{"quantity":1}).ok and JSON.stringify(farm.state)==before,"Failed feature write does not debit or grant")
	farm.store.fail_write = false
	check(farm.load_farm(farm.fixture()),"Recover by reopening unchanged save")
	var corrupted: Dictionary = farm.state.features.duplicate(true)
	corrupted.goods["forged"] = 1
	check(not farm.Features.valid(corrupted,farm.features_config),"Unknown goods rejected on validation")
