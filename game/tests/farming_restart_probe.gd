extends SceneTree
## Invoked by farming_tests in separate processes, only on dedicated test paths.
const Service = preload("res://scripts/services/farming/local_farm_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=2 or not args[1].begins_with(ProjectSettings.globalize_path("res://../.local/g11/tests")):
		quit(1)
		return
	var now := 1000.0 if args[0]=="plant" else 900000.0
	var farm := Service.new(Clock.new(func() -> float: return now),Store.new(args[1]))
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
	if not farm.load_farm(fixture):
		quit(1)
		return
	var command := {"request_id":"restart.plant","type":"plant","plot_id":"plot.0.0","crop_id":"crop.carrot"}
	if args[0]!="plant":
		var cycle: String = farm.state.receipts["restart.plant"].result.cycle_id
		command = {"request_id":"restart.harvest","type":"harvest","plot_id":"plot.0.0","crop_id":"","cycle_id":cycle}
	var result := farm.execute(command)
	var valid: bool = result.ok
	if args[0]!="plant":
		valid = valid and farm.state.inventory.products["crop.carrot"]==2
	if args[0]=="replay":
		valid = valid and result.get("replayed",false)
	print("Restart probe "+args[0]+": "+str(valid))
	quit(0 if valid else 1)
