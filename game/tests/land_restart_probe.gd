extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/land/local_land_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
var serial: int = 0

func _initialize() -> void:
	call_deferred("run")

func execute(farm: RefCounted, type: String, payload: Dictionary) -> Dictionary:
	serial += 1
	payload.merge({"request_id":"probe.earn."+str(serial),"type":type})
	return farm.execute(payload)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=2 or not args[1].contains("/.local/g14/tests/"):
		quit(1)
		return
	var time := Base.ControlledTime.new()
	var farm := Service.new(Clock.new(time.now,1,"probe.land.v4"),Store.new(args[1]),func() -> float: return 1)
	if not farm.load_farm(farm.fixture()):
		quit(1)
		return
	var ok: bool = true
	match args[0]:
		"earn":
			for i in range(8):
				if farm.state.inventory.seeds.get("crop.carrot",0)<1:
					execute(farm,"buy_seeds",{"crop_id":"crop.carrot","quantity":1})
				var planted := execute(farm,"plant",{"plot_id":"plot.home.a","crop_id":"crop.carrot"})
				time.value += 128
				execute(farm,"harvest",{"plot_id":"plot.home.a","cycle_id":planted.cycle_id})
				execute(farm,"sell_products",{"items":{"crop.carrot":2}})
			ok = farm.state.economy.coins==80 and farm.state.economy.level==2
		"unlock":
			time.value = 3000
			ok = farm.execute({"request_id":"probe.unlock","type":"unlock_plot","plot_id":"plot.expand.1","confirmed":true,"expected_revision":farm.state.revision,"quote_version":farm.land_config.version}).ok and farm.state.economy.coins==40
		"replay":
			time.value = 4000
			var revision: int = int(farm.state.receipts["probe.unlock"].result.revision)-1
			ok = farm.execute({"request_id":"probe.unlock","type":"unlock_plot","plot_id":"plot.expand.1","confirmed":true,"expected_revision":revision,"quote_version":farm.land_config.version}).get("replayed",false)
			ok = ok and farm.state.economy.coins==40 and not farm.state.plots["plot.expand.1"].locked and farm.state.land.history.size()==1
		"plant":
			time.value = 5000
			farm.execute({"request_id":"probe.buy.seed","type":"buy_seeds","crop_id":"crop.carrot","quantity":1})
			ok = farm.execute({"request_id":"probe.plant.new","type":"plant","plot_id":"plot.expand.1","crop_id":"crop.carrot"}).ok and farm.state.economy.coins==38
		_:
			ok = false
	if not ok:
		push_error("Land restart phase failed: "+args[0])
	quit(0 if ok else 1)
