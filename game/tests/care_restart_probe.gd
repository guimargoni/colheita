extends SceneTree
const Service = preload("res://scripts/services/care/local_care_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=2 or not args[1].begins_with(ProjectSettings.globalize_path("res://../.local/g12/tests")):
		quit(1)
		return
	var now := 1000.0 if args[0]=="plant" else 4000.0 if args[0]=="care" else 20000.0
	var roll := 0.0 if args[0]=="plant" else 1.0
	var farm := Service.new(Clock.new(func() -> float: return now),Store.new(args[1]),func() -> float: return roll)
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
	if not farm.load_farm(fixture):
		quit(1)
		return
	if args[0]=="plant":
		if not farm.execute({"request_id":"restart.plant","type":"plant","plot_id":"plot.0.0","crop_id":"crop.wheat"}).ok:
			quit(1)
			return
	var cycle: String = farm.state.receipts["restart.plant"].result.cycle_id
	var fertilize := {"request_id":"restart.fertilize","type":"fertilize","plot_id":"plot.0.0","cycle_id":cycle,"item_id":"fertilizer.common"}
	var ok: bool = true
	if args[0]=="plant":
		ok = farm.execute({"request_id":"restart.water","type":"water","plot_id":"plot.0.0","cycle_id":cycle}).ok
		ok = ok and farm.execute(fertilize).ok
	else:
		ok = farm.execute(fertilize).get("replayed",false) and farm.state.inventory.fertilizers["fertilizer.common"]==7
	if args[0]=="care":
		ok = ok and farm.snapshot().plots["plot.0.0"].growth.care.pests
		ok = ok and farm.execute({"request_id":"restart.remove","type":"remove_pests","plot_id":"plot.0.0","cycle_id":cycle}).ok
	if args[0] in ["harvest","replay"]:
		ok = ok and farm.execute({"request_id":"restart.harvest","type":"harvest","plot_id":"plot.0.0","cycle_id":cycle}).ok
		ok = ok and farm.state.inventory.products["crop.wheat"]==4
	print("Care restart "+args[0]+": "+str(ok))
	quit(0 if ok else 1)
