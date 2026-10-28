extends RefCounted
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/integrated/farm_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var serial: int = 0
func command(farm: RefCounted,type: String,args: Dictionary = {}) -> Dictionary:
	serial += 1; args.type = type; args.request_id = "sample."+str(serial)
	var result: Dictionary = farm.execute(args)
	if not result.ok: push_error("Sample command: "+str(result))
	return result
func create() -> RefCounted:
	var time := Base.ControlledTime.new()
	time.value = Time.get_unix_time_from_system()
	var farm := Service.new(Clock.new(time.now,1,"capture.integrated.v1"),Base.MemoryStore.new(),func() -> float: return 1)
	farm.load_farm(farm.fixture())
	while farm.state.economy.xp<220:
		if farm.state.inventory.seeds.get("crop.carrot",0)<1: command(farm,"buy_seeds",{"crop_id":"crop.carrot","quantity":1})
		var plant := command(farm,"plant",{"plot_id":"plot.home.a","crop_id":"crop.carrot"})
		time.value += 140
		command(farm,"harvest",{"plot_id":"plot.home.a","cycle_id":plant.cycle_id})
		command(farm,"sell_products",{"items":{"crop.carrot":2}})
	command(farm,"buy_feed",{"quantity":20})
	for kind in farm.features_config.producers:
		var result := command(farm,"buy_producer",{"kind":kind})
		command(farm,"producer_feed",{"id":result.id})
	command(farm,"buy_decoration",{"kind":"flowerpot","slot":0})
	command(farm,"buy_decoration",{"kind":"well","slot":5})
	command(farm,"buy_decoration",{"kind":"bench","slot":3})
	command(farm,"build",{"kind":"bouquet_workshop"})
	command(farm,"build",{"kind":"house"})
	command(farm,"guardian_buy")
	command(farm,"guardian_feed")
	var crops := ["crop.bean","crop.rose","crop.apple","crop.carrot"]
	var plots := ["plot.home.a","plot.home.b","plot.home.c","plot.home.d"]
	for i in range(4):
		command(farm,"buy_seeds",{"crop_id":crops[i],"quantity":2})
		command(farm,"plant",{"plot_id":plots[i],"crop_id":crops[i]})
	time.value += 1900
	return farm
