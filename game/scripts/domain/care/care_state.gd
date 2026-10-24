extends RefCounted
const Base = preload("res://scripts/domain/farming/farm_state.gd")
const Rules = preload("res://scripts/domain/care/care_rules.gd")

static func create(fixture: Dictionary, profile: String, items: Dictionary) -> Dictionary:
	var state := Base.create(fixture,profile)
	state.schema_version = 2
	state.catalog_version = "g12.care.v1"
	state.inventory.fertilizers = {}
	for id in items:
		state.inventory.fertilizers[id] = int(items[id].initial_quantity)
	for plot in state.plots.values():
		plot.care = Rules.empty_care()
	return state

static func valid(state: Dictionary, catalog: RefCounted, profile: String, items: Dictionary) -> bool:
	if state.get("schema_version")!=2 or state.get("catalog_version")!="g12.care.v1":
		return false
	var copy := state.duplicate(true)
	copy.schema_version = 1
	copy.catalog_version = "g11.crops.v1"
	if not Base.valid(copy,catalog,profile) or not state.inventory.get("fertilizers") is Dictionary:
		return false
	for id in state.inventory.fertilizers:
		var count = state.inventory.fertilizers[id]
		if not items.has(id) or not Base.number(count) or count<0 or count!=int(count):
			return false
	for plot in state.plots.values():
		var care: Dictionary = plot.care
		if not care.get("history") is Array or not care.get("nuisances") is Dictionary or not Base.number(care.get("water_count")) or care.water_count<0:
			return false
		if care.water_count!=int(care.water_count) or not Base.number(care.get("water_acceleration")) or care.water_acceleration<0:
			return false
		for key in ["watered_at","hydrated_until"]:
			if not care.has(key) or (care[key]!=null and not Base.number(care[key])):
				return false
		for row in care.history:
			if not row is Dictionary or not row.get("request_id") is String or not row.get("action") is String or not Base.number(row.get("at")):
				return false
		for row in plot.modifiers:
			if not row is Dictionary or not items.has(row.get("item_id")) or not row.get("request_id") is String or not Base.number(row.get("ready_at")):
				return false
		if not plot.crop_id.is_empty():
			if not care.get("policy") is Dictionary or not Rules.valid_policy(care.policy,catalog):
				return false
			for kind in ["weeds","pests"]:
				if not care.nuisances.get(kind) is Dictionary:
					return false
				var row: Dictionary = care.nuisances[kind]
				for key in ["appears_at","removed_at"]:
					if not row.has(key) or (row[key]!=null and not Base.number(row[key])):
						return false
	return true
