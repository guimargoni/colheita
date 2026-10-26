extends RefCounted
const Care = preload("res://scripts/domain/care/care_state.gd")
const Economy = preload("res://scripts/domain/land/land_economy_rules.gd")
const Land = preload("res://scripts/domain/land/land_rules.gd")

static func create(fixture: Dictionary, profile: String, items: Dictionary, economy: Dictionary, land: Dictionary, now: float) -> Dictionary:
	var state := Care.create(fixture,profile,items)
	Economy.initialize(state,economy,now)
	state.schema_version = 4
	state.catalog_version = land.version
	state.land = {"version":land.version,"history":[]}
	return state

static func valid(state: Dictionary, catalog: RefCounted, profile: String, items: Dictionary, economy: Dictionary, land: Dictionary) -> bool:
	if state.get("schema_version")!=4 or state.get("catalog_version")!=land.version or state.get("farm_id")!=land.farm_id or state.get("owner_id")!=land.owner_id:
		return false
	var copy := state.duplicate(true)
	copy.schema_version = 2
	copy.catalog_version = "g12.care.v1"
	return Care.valid(copy,catalog,profile,items) and Economy.valid(state,economy) and Land.valid(state,land)
