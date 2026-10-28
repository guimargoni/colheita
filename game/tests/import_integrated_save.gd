extends SceneTree
const Service = preload("res://scripts/services/integrated/farm_service.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
const Migration = preload("res://scripts/domain/integrated/save_migration.gd")
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=3 or args[2] not in ["normal","fast"]: push_error("Use SOURCE NEW_DEST normal|fast"); quit(1); return
	var source := ProjectSettings.globalize_path(args[0]); var destination := ProjectSettings.globalize_path(args[1])
	if source.to_lower()==destination.to_lower() or FileAccess.file_exists(destination) or FileAccess.file_exists(destination+".tmp"): push_error("Destination exists; overwrite refused"); quit(1); return
	var raw := FileAccess.get_file_as_string(source)
	var parsed = JSON.parse_string(raw)
	if not parsed is Dictionary: push_error("Invalid source"); quit(1); return
	var fast: bool = args[2]=="fast"
	var farm := Service.new(Clock.new(Callable(),60 if fast else 1,"integrated.fast60.v1" if fast else "integrated.real.v1"),Store.new(destination))
	var result: Dictionary = Migration.convert(parsed,fast,farm)
	if not result.ok: push_error(str(result)); quit(1); return
	farm.economy_config.initial_coins = result.state.genesis_coins
	if not farm.State.valid(result.state,farm.catalog,farm.clock.profile,farm.items,farm.economy_config,result.state.layout) or not farm.Features.valid(result.state.features,farm.features_config): push_error("Migrated state invalid"); quit(1); return
	if not farm.store.commit(result.state,-1) or FileAccess.get_file_as_string(source)!=raw: push_error("Copy import failed"); quit(1); return
	print("Integrated COPY migration PASS; original bytes preserved; new local save only")
	quit()
