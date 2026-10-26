extends RefCounted
const Care = preload("res://scripts/domain/care/care_state.gd")
const Economy = preload("res://scripts/domain/cultures/culture_economy.gd")
const Land = preload("res://scripts/domain/cultures/culture_land.gd")
const Repeat = preload("res://scripts/domain/cultures/repeat_rules.gd")
const Seasons = preload("res://scripts/domain/cultures/season_rules.gd")

static func create(fixture: Dictionary, profile: String, items: Dictionary, economy: Dictionary, land: Dictionary, now: float) -> Dictionary:
	var state := Care.create(fixture,profile,items)
	Economy.initialize(state,economy,now)
	state.schema_version = 5
	state.catalog_version = "g15.crops.v1"
	state.land = {"version":land.version,"history":[]}
	state.layout = land.duplicate(true)
	state.genesis_coins = int(economy.initial_coins)
	state.seasonal = {"counts":{},"acquisitions":[]}
	state.migration = null
	for plot in state.plots.values():
		plot.series = null
	return state

static func valid(state: Dictionary, catalog: RefCounted, profile: String, items: Dictionary, economy: Dictionary, land: Dictionary) -> bool:
	if state.get("schema_version")!=5 or state.get("catalog_version")!="g15.crops.v1" or state.get("layout")!=land or state.get("farm_id")!=land.farm_id or state.get("owner_id")!=land.owner_id or state.get("genesis_coins")!=economy.initial_coins:
		return false
	var copy := state.duplicate(true)
	copy.schema_version = 2
	copy.catalog_version = "g12.care.v1"
	if not Care.valid(copy,catalog,profile,items) or not Economy.valid(state,economy) or not Land.valid(state,land) or not Seasons.valid(state):
		return false
	for plot in state.plots.values():
		if not Repeat.valid(plot):
			return false
	return true
