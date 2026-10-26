extends SceneTree
const Service = preload("res://scripts/services/cultures/local_culture_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const Migration = preload("res://scripts/domain/cultures/save_migration.gd")
const State = preload("res://scripts/domain/cultures/culture_state.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=3:
		push_error("Expected SOURCE DESTINATION normal|fast")
		quit(1)
		return
	var source := ProjectSettings.globalize_path(args[0])
	var destination := ProjectSettings.globalize_path(args[1])
	if source.to_lower()==destination.to_lower() or FileAccess.file_exists(destination) or FileAccess.file_exists(destination+".tmp"):
		push_error("Destination exists or equals source; no overwrite allowed")
		quit(1)
		return
	var raw := FileAccess.get_file_as_string(source)
	var parsed = JSON.parse_string(raw)
	if not parsed is Dictionary:
		push_error("Source is not valid JSON; untouched")
		quit(1)
		return
	var fast: bool = args[2]=="fast"
	if args[2] not in ["normal","fast"]:
		quit(1)
		return
	var profile := "local.cultures.fast60.v5" if fast else "local.cultures.real.v5"
	var farm := Service.new(Clock.new(Callable(),60 if fast else 1,profile),Store.new(destination))
	var result := Migration.convert(parsed,profile,farm.catalog,farm.policy,farm.items,farm.economy_config,farm.land_config)
	if not result.ok:
		push_error("Import refused: "+result.error)
		quit(1)
		return
	farm.economy_config.initial_coins = int(result.state.genesis_coins)
	if not State.valid(result.state,farm.catalog,profile,farm.items,farm.economy_config,result.state.layout):
		push_error("Migrated copy failed validation; source untouched")
		quit(1)
		return
	if not farm.store.commit(result.state,-1) or FileAccess.get_file_as_string(source)!=raw:
		push_error("Import could not be confirmed")
		quit(1)
		return
	print("G1.5 import PASS: source preserved, new save: "+destination)
	quit(0)
