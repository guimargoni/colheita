extends RefCounted

static func create(fixture: Dictionary, profile: String) -> Dictionary:
	var plots: Dictionary = {}
	for item in fixture.plots:
		plots[item.id] = {"id":item.id,"grid":item.grid.duplicate(),"region_id":item.region_id,"locked":item.locked,"owner_id":fixture.owner_id,"cultivation_state":"empty","crop_id":"","cycle_id":"","planted_at":null,"ready_at":null,"base_duration":null,"care":{"watered_at":null,"last_helper_id":null},"modifiers":[],"social":{"protected_yield":null,"theft_taken":0,"helper_ids":[]}}
	return {"schema_version":1,"catalog_version":"g11.crops.v1","farm_id":fixture.farm_id,"owner_id":fixture.owner_id,"clock_profile":profile,"revision":0,"next_cycle":1,"plots":plots,"inventory":{"seeds":fixture.initial_seeds.duplicate(true),"products":{}},"receipts":{}}

static func number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))

static func valid(data: Dictionary, catalog: RefCounted, profile: String) -> bool:
	if data.get("schema_version")!=1 or data.get("catalog_version")!="g11.crops.v1" or data.get("clock_profile")!=profile:
		return false
	for key in ["farm_id","owner_id"]:
		if not data.get(key) is String or data[key].is_empty():
			return false
	for key in ["revision","next_cycle"]:
		if not number(data.get(key)) or data[key]<0 or data[key]!=int(data[key]):
			return false
	if not data.get("plots") is Dictionary or not data.get("inventory") is Dictionary or not data.get("receipts") is Dictionary:
		return false
	for kind in ["seeds","products"]:
		if not data.inventory.get(kind) is Dictionary:
			return false
		for key in data.inventory[kind]:
			var quantity = data.inventory[kind][key]
			if not catalog.entries.has(key) or not number(quantity) or quantity<0 or quantity!=int(quantity):
				return false
	var cycles: Dictionary = {}
	for id in data.plots:
		var plot = data.plots[id]
		if not plot is Dictionary or plot.get("id")!=id or not plot.get("locked") is bool or not plot.get("grid") is Array or plot.grid.size()!=2:
			return false
		for coordinate in plot.grid:
			if not number(coordinate):
				return false
		for key in ["region_id","owner_id","crop_id","cycle_id","cultivation_state"]:
			if not plot.get(key) is String:
				return false
		if not plot.get("care") is Dictionary or not plot.get("social") is Dictionary or not plot.get("modifiers") is Array:
			return false
		if plot.crop_id.is_empty():
			if plot.cultivation_state!="empty" or not plot.cycle_id.is_empty() or plot.get("planted_at")!=null or plot.get("ready_at")!=null:
				return false
		else:
			if not catalog.entries.has(plot.crop_id) or plot.cultivation_state!="planted" or plot.cycle_id.is_empty() or cycles.has(plot.cycle_id):
				return false
			cycles[plot.cycle_id] = true
			if not number(plot.get("planted_at")) or not number(plot.get("ready_at")) or not number(plot.get("base_duration")) or plot.planted_at<0 or plot.ready_at<=plot.planted_at or plot.base_duration<=0:
				return false
	for receipt in data.receipts.values():
		if not receipt is Dictionary or not receipt.get("fingerprint") is String or not receipt.get("result") is Dictionary or receipt.result.get("ok")!=true:
			return false
	return data.next_cycle>=1
