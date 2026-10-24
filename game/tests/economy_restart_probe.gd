extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/economy/local_economy_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=2 or not args[1].contains("/.local/g13/tests/"):
		quit(1)
		return
	var time := Base.ControlledTime.new()
	var farm := Service.new(Clock.new(time.now,1,"probe.economy.v3"),Store.new(args[1]),func() -> float: return 1)
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
	if not farm.load_farm(fixture):
		quit(1)
		return
	var buy := {"request_id":"probe.buy","type":"buy_seeds","crop_id":"crop.carrot","quantity":2}
	var sale := {"request_id":"probe.sell","type":"sell_products","items":{"crop.carrot":2}}
	var ok: bool = true
	match args[0]:
		"buy":
			ok = farm.execute(buy).ok and farm.state.economy.coins==36
		"harvest":
			var plant: Dictionary = farm.execute({"request_id":"probe.plant","type":"plant","plot_id":"plot.0.0","crop_id":"crop.carrot"})
			time.value += 128
			ok = plant.ok and farm.execute({"request_id":"probe.harvest","type":"harvest","plot_id":"plot.0.0","cycle_id":plant.cycle_id}).ok and farm.state.economy.xp==1
		"sell":
			ok = farm.execute(sale).ok and farm.state.economy.coins==42
		"replay":
			var cycle: String = farm.state.receipts["probe.harvest"].result.cycle_id
			ok = farm.execute(buy).get("replayed",false) and farm.execute(sale).get("replayed",false) and farm.execute({"request_id":"probe.harvest","type":"harvest","plot_id":"plot.0.0","cycle_id":cycle}).get("replayed",false)
			ok = ok and farm.state.economy.coins==42 and farm.state.economy.xp==1 and farm.state.inventory.products["crop.carrot"]==0 and farm.state.inventory.seeds["crop.carrot"]==5 and farm.state.economy.ledger.size()==3
		_:
			ok = false
	if not ok:
		push_error("Economy restart phase failed: "+args[0])
	quit(0 if ok else 1)
