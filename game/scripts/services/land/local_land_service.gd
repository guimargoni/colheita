extends "res://scripts/services/farming/farm_service.gd"
## G1.4 isolated single-writer DEV economy; previous providers untouched.

signal event_emitted(event: Dictionary)
const Catalog = preload("res://scripts/domain/farming/crop_catalog.gd")
const State = preload("res://scripts/domain/land/land_state.gd")
const Economy = preload("res://scripts/domain/land/land_economy_rules.gd")
const Land = preload("res://scripts/domain/land/land_rules.gd")
var land_config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/g14/land.json"))
var economy_config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/g13/economy.json"))
const Growth = preload("res://scripts/domain/care/care_rules.gd")
const Inventory = preload("res://scripts/domain/farming/inventory.gd")
const Care = preload("res://scripts/domain/care/care_commands.gd")
var policy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/g12/care.json"))
var items: Dictionary = {}
var roll: Callable
var catalog = Catalog.new()
var clock: RefCounted
var store: RefCounted
var state: Dictionary = {}
var error: String = "not_loaded"
var authority: String = "LOCAL_DEVELOPMENT_UNTRUSTED"

func _init(time_service: RefCounted, persistence: RefCounted, random_source: Callable = Callable()) -> void:
	clock = time_service
	store = persistence
	roll = random_source if random_source.is_valid() else func() -> float: return randf()
	var definitions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/g12/fertilizers.json"))
	for item in definitions.items:
		items[item.id] = item

func load_farm(fixture: Dictionary) -> bool:
	error = catalog.error if Growth.valid_policy(policy,catalog) else "invalid_care_policy"
	if not is_finite(clock.now_seconds()) or clock.now_seconds()<0:
		error = "invalid_clock"
	if not Economy.valid_config(economy_config,catalog):
		error = "invalid_economy_config"
	elif not Land.valid_config(land_config,economy_config):
		error = "invalid_land_config"
	if not valid_items():
		error = "invalid_fertilizer_catalog"
	if not error.is_empty():
		return false
	var loaded: Dictionary = store.read()
	if not loaded.ok:
		error = loaded.error
		return false
	var candidate: Dictionary = State.create(fixture,clock.profile,items,economy_config,land_config,clock.now_seconds()) if loaded.missing else loaded.state
	if not State.valid(candidate,catalog,clock.profile,items,economy_config,land_config):
		error = "save_schema_or_profile_invalid"
		return false
	if loaded.missing and not store.commit(candidate,-1):
		error = store.error
		return false
	state = candidate
	return true

func valid_items() -> bool:
	if items.size()!=4:
		return false
	for id in items:
		var item: Dictionary = items[id]
		for key in ["reduction_fraction","initial_quantity","max_uses_per_cycle"]:
			var number = item.get(key)
			if not (number is int or number is float) or not is_finite(float(number)):
				return false
		if item.reduction_fraction<=0 or item.reduction_fraction>=1 or item.initial_quantity<0 or item.initial_quantity!=int(item.initial_quantity) or item.max_uses_per_cycle<1 or item.max_uses_per_cycle!=int(item.max_uses_per_cycle):
			return false
		if not item.get("compatible_crops") is Array or not item.get("rare") is bool or item.get("scope") not in ["owner","friend_future"]:
			return false
		for crop in item.compatible_crops:
			if not catalog.entries.has(crop):
				return false
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
	for key in ["request_id","type"]:
		if not command.get(key) is String or command[key].is_empty():
			return fail("invalid_command")
	if command.request_id=="genesis":
		return fail("reserved_operation_id")
	if command.type not in ["plant","harvest","water","remove_weeds","remove_pests","fertilize","buy_seeds","sell_products","unlock_plot"]:
		return fail("feature_not_enabled")
	if command.get("actor_id",state.owner_id)!=state.owner_id:
		return fail("foreign_actor")
	if command.type=="buy_seeds" and (not Economy.integer(command.get("quantity"),int(economy_config.max_quantity)) or command.quantity<1):
		return fail("invalid_quantity_or_crop")
	if command.type=="sell_products":
		if not command.get("items") is Dictionary:
			return fail("invalid_selection")
		for id in command.items:
			if not id is String or not Economy.integer(command.items[id],int(economy_config.max_value)) or command.items[id]<1:
				return fail("invalid_quantity_or_crop")
	var selection: Array = []
	if command.get("items") is Dictionary:
		var keys: Array = command.items.keys()
		keys.sort()
		for id in keys:
			selection.append([id,int(command.items[id])])
	var quantity: Variant = command.get("quantity")
	if Economy.integer(quantity):
		quantity = int(quantity)
	var expected: Variant = command.get("expected_revision")
	if Economy.integer(expected):
		expected = int(expected)
	var fingerprint := JSON.stringify([command.type,command.get("plot_id",""),command.get("crop_id",""),command.get("cycle_id",""),command.get("item_id",""),command.get("rare_ack",false),quantity,selection,command.get("confirmed",false),expected,command.get("quote_version")])
	if state.receipts.has(command.request_id):
		var receipt: Dictionary = state.receipts[command.request_id]
		if receipt.fingerprint!=fingerprint:
			return fail("request_id_conflict")
		var repeated: Dictionary = receipt.result.duplicate(true)
		repeated.replayed = true
		return repeated
	if command.type in ["buy_seeds","sell_products","unlock_plot"]:
		return trade(command,fingerprint)
	if not command.get("plot_id") is String or not state.plots.has(command.plot_id):
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
		if crop.id not in next.economy.unlocks:
			return fail("crop_level_locked")
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
		Growth.start(plot,policy,roll)
		result = {"ok":true,"action":"plant","crop_id":crop.id,"cycle_id":plot.cycle_id}
	elif command.type=="harvest":
		if not command.get("cycle_id") is String or command.cycle_id.is_empty() or command.cycle_id!=plot.cycle_id:
			return fail("cycle_mismatch")
		var crop: Dictionary = catalog.entries[plot.crop_id]
		if Growth.view(plot,crop,now).state!="mature":
			return fail("not_mature")
		if next.inventory.products.get(crop.id,0)+crop.yield_quantity>economy_config.max_value:
			return fail("value_limit")
		Inventory.credit(next.inventory.products,crop.id,int(crop.yield_quantity))
		result = {"ok":true,"action":"harvest","crop_id":crop.id,"cycle_id":plot.cycle_id,"quantity":int(crop.yield_quantity),"care_history":plot.care.history.duplicate(true),"modifiers":plot.modifiers.duplicate(true),"nuisances":plot.care.nuisances.duplicate(true)}
		var reward: Dictionary = Economy.reward(next,crop.id,economy_config)
		if not reward.ok:
			return reward
		result.merge(reward)
		plot.crop_id = ""
		plot.cycle_id = ""
		plot.cultivation_state = "empty"
		plot.planted_at = null
		plot.ready_at = null
		plot.base_duration = null
		plot.care = Growth.empty_care()
		plot.modifiers = []
	else:
		result = Care.execute(next,plot,command,now,items)
		if not result.ok:
			return result
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

func trade(command: Dictionary, fingerprint: String) -> Dictionary:
	var now: float = clock.now_seconds()
	if not is_finite(now) or now<0:
		return fail("invalid_clock")
	var next := state.duplicate(true)
	var result: Dictionary
	if command.type=="unlock_plot":
		if not command.get("plot_id") is String:
			return fail("unknown_plot")
		result = Land.unlock(next,land_config,command,now)
	else:
		result = Economy.trade(next,command,economy_config,now)
	if not result.ok:
		return result
	next.revision += 1
	result.revision = next.revision
	next.receipts[command.request_id] = {"fingerprint":fingerprint,"result":result.duplicate(true)}
	if not store.commit(next,int(state.revision)):
		error = store.error
		return fail(error)
	state = next
	event_emitted.emit({"event":result.action,"authority":authority,"request_id":command.request_id,"transaction_id":result.transaction_id,"revision":state.revision})
	return result

func fixture() -> Dictionary:
	return Land.fixture(land_config,economy_config)

func land_quote(id: String) -> Dictionary:
	return Land.quote(state,land_config,id) if not state.is_empty() else fail(error)
