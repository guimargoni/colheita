extends RefCounted
const Old = preload("res://scripts/services/cultures/local_culture_service.gd")
const OldMigration = preload("res://scripts/domain/cultures/save_migration.gd")
const OldState = preload("res://scripts/domain/cultures/culture_state.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
static func convert(source: Dictionary, fast: bool, target: RefCounted) -> Dictionary:
	var old := Old.new(Clock.new(),null)
	var profile := "local.cultures.fast60.v5" if fast else "local.cultures.real.v5"
	var candidate: Dictionary
	if source.get("schema_version")==5:
		if ("fast60" in str(source.get("clock_profile","")))!=fast: return {"ok":false,"error":"clock_rate_mismatch"}
		old.economy_config.initial_coins = source.get("genesis_coins",40)
		if not OldState.valid(source,old.catalog,source.get("clock_profile",""),old.items,old.economy_config,source.get("layout",{})): return {"ok":false,"error":"invalid_source"}
		candidate = source.duplicate(true)
	else:
		var result: Dictionary = OldMigration.convert(source,profile,old.catalog,old.policy,old.items,old.economy_config,old.land_config)
		if not result.ok: return result
		candidate = result.state
	candidate.clock_profile = target.clock.profile
	candidate.inventory.seeds["crop.apple"] = 0
	candidate.economy.shop_stock["crop.apple"] = int(target.economy_config.crops["crop.apple"].shop_stock)
	candidate.economy.unlocks = target.Economy.unlocked(int(candidate.economy.level),target.economy_config)
	for plot in candidate.plots.values():
		if not plot.crop_id.is_empty(): plot.care.policy.crops["crop.apple"] = target.policy.crops["crop.apple"].duplicate(true)
	candidate.features = target.Features.fresh()
	candidate.integrated_migration = {"source_schema":source.schema_version,"source_hash":JSON.stringify(source).sha256_text()}
	candidate.revision += 1
	return {"ok":true,"state":candidate}
