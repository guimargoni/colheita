extends "res://scripts/services/farming/farm_service.gd"
## Single-writer local DEVELOPMENT implementation, replace with remote authority.

signal event_emitted(event: Dictionary)
const Catalog = preload("res://scripts/domain/farming/crop_catalog.gd")
const State = preload("res://scripts/domain/farming/farm_state.gd")
const Growth = preload("res://scripts/domain/farming/growth_rules.gd")
const Inventory = preload("res://scripts/domain/farming/inventory.gd")
var catalog = Catalog.new()
var clock: RefCounted
var store: RefCounted
var state: Dictionary = {}
var error: String = "not_loaded"
var authority: String = "LOCAL_DEVELOPMENT_UNTRUSTED"

func _init(time_service: RefCounted, persistence: RefCounted) -> void:
	clock = time_service
	store = persistence

func load_farm(fixture: Dictionary) -> bool:
	error = catalog.error
	if not error.is_empty():
		return false
	var loaded: Dictionary = store.read()
	if not loaded.ok:
		error = loaded.error
		return false
	var candidate: Dictionary = State.create(fixture,clock.profile) if loaded.missing else loaded.state
	if not State.valid(candidate,catalog,clock.profile):
		error = "save_schema_or_profile_invalid"
		return false
	if loaded.missing and not store.commit(candidate,-1):
		error = store.error
		return false
	state = candidate
	return true

func snapshot() -> Dictionary:
	if state.is_empty():
		return {}
	var copy := state.duplicate(true)
	var now: float = clock.now_seconds()
	for plot in copy.plots.values():
		plot.growth = Growth.view(plot,catalog.entries.get(plot.crop_id,{}),now)
		plot.state = plot.growth.state
	return copy

func fail(reason: String) -> Dictionary:
	return {"ok":false,"error":reason}

func execute(command: Dictionary) -> Dictionary:
	if not error.is_empty():
		return fail(error)
	for key in ["request_id","type","plot_id"]:
		if not command.get(key) is String or command[key].is_empty():
			return fail("invalid_command")
	if command.type not in ["plant","harvest"]:
		return fail("feature_not_enabled")
	var fingerprint := JSON.stringify([command.type,command.plot_id,command.get("crop_id",""),command.get("cycle_id","")])
	if state.receipts.has(command.request_id):
		var receipt: Dictionary = state.receipts[command.request_id]
		if receipt.fingerprint!=fingerprint:
			return fail("request_id_conflict")
		var repeated: Dictionary = receipt.result.duplicate(true)
		repeated.replayed = true
		return repeated
	if not state.plots.has(command.plot_id):
		return fail("unknown_plot")
	var next := state.duplicate(true)
	var plot: Dictionary = next.plots[command.plot_id]
	if plot.locked:
		return fail("plot_locked")
	var now: float = clock.now_seconds()
	if not is_finite(now) or now<0:
		return fail("invalid_clock")
	var result: Dictionary
	if command.type=="plant":
		if not plot.crop_id.is_empty():
			return fail("plot_occupied")
		if not catalog.entries.has(command.get("crop_id")):
			return fail("unknown_crop")
		var crop: Dictionary = catalog.entries[command.crop_id]
		if not Inventory.consume(next.inventory.seeds,crop.id,1):
			return fail("no_seeds")
		plot.crop_id = crop.id
		plot.cultivation_state = "planted"
		plot.cycle_id = next.farm_id+"/cycle/"+str(int(next.next_cycle))
		next.next_cycle += 1
		plot.planted_at = now
		plot.base_duration = crop.growth_seconds
		plot.ready_at = now+float(crop.growth_seconds)
		plot.modifiers = []
		result = {"ok":true,"action":"plant","crop_id":crop.id,"cycle_id":plot.cycle_id}
	else:
		if not command.get("cycle_id") is String or command.cycle_id.is_empty() or command.cycle_id!=plot.cycle_id:
			return fail("cycle_mismatch")
		var crop: Dictionary = catalog.entries[plot.crop_id]
		if Growth.view(plot,crop,now).state!="mature":
			return fail("not_mature")
		Inventory.credit(next.inventory.products,crop.id,int(crop.yield_quantity))
		result = {"ok":true,"action":"harvest","crop_id":crop.id,"cycle_id":plot.cycle_id,"quantity":int(crop.yield_quantity)}
		plot.crop_id = ""
		plot.cycle_id = ""
		plot.cultivation_state = "empty"
		plot.planted_at = null
		plot.ready_at = null
		plot.base_duration = null
		plot.care = {"watered_at":null,"last_helper_id":null}
		plot.modifiers = []
	next.revision += 1
	result.revision = next.revision
	result.plot_id = plot.id
	next.receipts[command.request_id] = {"fingerprint":fingerprint,"result":result.duplicate(true)}
	if not store.commit(next,int(state.revision)):
		error = store.error
		return fail(error)
	state = next
	event_emitted.emit({"event":"crop_"+result.action,"authority":authority,"farm_id":state.farm_id,"plot_id":plot.id,"cycle_id":result.cycle_id,"request_id":command.request_id,"revision":state.revision})
	return result
