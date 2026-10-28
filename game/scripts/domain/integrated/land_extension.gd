extends RefCounted
## Additive, versioned capacity migration. Never move existing plots or grant value.
static func extend(state: Dictionary) -> Dictionary:
	var next: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/integrated/land.json"))
	var previous: Dictionary = state.layout
	if previous.plots.size()!=8: return {"ok":true,"changed":false,"state":state}
	for i in range(8):
		if previous.plots[i]!=next.plots[i]: return {"ok":true,"changed":false,"state":state}
	var candidate := state.duplicate(true)
	next.farm_id = state.farm_id; next.owner_id = state.owner_id
	for row in next.plots.slice(8):
		var plot: Dictionary = candidate.plots["plot.home.a"].duplicate(true)
		# Construct an empty plot instead of copying any active care/series/reward state.
		plot = {"id":row.id,"grid":row.grid.duplicate(),"region_id":row.region_id,"locked":true,"owner_id":state.owner_id,"cultivation_state":"empty","crop_id":"","cycle_id":"","planted_at":null,"ready_at":null,"base_duration":null,"care":preload("res://scripts/domain/care/care_rules.gd").empty_care(),"modifiers":[],"social":{"protected_yield":null,"theft_taken":0,"helper_ids":[]},"series":null}
		candidate.plots[row.id] = plot
	candidate.layout = next
	candidate.land_capacity_revision = 2
	candidate.revision += 1
	return {"ok":true,"changed":true,"state":candidate}
