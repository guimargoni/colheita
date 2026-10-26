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
	print("Integrated farm checks: %d; failures: %d"%[checks,failures])
	quit(1 if failures else 0)
