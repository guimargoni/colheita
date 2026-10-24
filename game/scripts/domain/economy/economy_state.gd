extends RefCounted
const Care = preload("res://scripts/domain/care/care_state.gd")
const Rules = preload("res://scripts/domain/economy/economy_rules.gd")

static func create(fixture: Dictionary, profile: String, items: Dictionary, config: Dictionary, now: float) -> Dictionary:
	var state := Care.create(fixture,profile,items)
	Rules.initialize(state,config,now)
	return state

static func valid(state: Dictionary, catalog: RefCounted, profile: String, items: Dictionary, config: Dictionary) -> bool:
	if state.get("schema_version")!=3 or state.get("catalog_version")!=config.version:
		return false
	var copy := state.duplicate(true)
	copy.schema_version = 2
	copy.catalog_version = "g12.care.v1"
	return Care.valid(copy,catalog,profile,items) and Rules.valid(state,config)
