extends RefCounted

static func event_for(events: Dictionary, crop: String) -> Dictionary:
	for id in events:
		if events[id].crop_id==crop:
			var copy: Dictionary = events[id].duplicate(true)
			copy.id = id
			return copy
	return {}

static func check_purchase(state: Dictionary, command: Dictionary, events: Dictionary, calendar: float) -> Dictionary:
	if command.type!="buy_seeds":
		return {"ok":true}
	var event := event_for(events,command.get("crop_id",""))
	if event.is_empty():
		return {"ok":true}
	if not is_finite(calendar) or calendar<event.start or calendar>=event.end:
		return {"ok":false,"error":"season_unavailable"}
	if state.seasonal.counts.get(event.id,0)+command.quantity>event.max_acquired:
		return {"ok":false,"error":"season_acquisition_limit"}
	return {"ok":true}

static func record_purchase(state: Dictionary, command: Dictionary, events: Dictionary, calendar: float) -> void:
	if command.type!="buy_seeds":
		return
	var event := event_for(events,command.crop_id)
	if event.is_empty():
		return
	state.seasonal.counts[event.id] = state.seasonal.counts.get(event.id,0)+int(command.quantity)
	state.seasonal.acquisitions.append({"event_id":event.id,"crop_id":command.crop_id,"quantity":int(command.quantity),"at":calendar,"operation_id":command.request_id})

static func valid(state: Dictionary) -> bool:
	if not state.get("seasonal") is Dictionary or not state.seasonal.get("counts") is Dictionary or not state.seasonal.get("acquisitions") is Array:
		return false
	var counts: Dictionary = {}
	var operations: Dictionary = {}
	for row in state.seasonal.acquisitions:
		if not row is Dictionary or not row.get("event_id") is String or not row.get("crop_id") is String or not state.receipts.has(row.get("operation_id")) or operations.has(row.operation_id):
			return false
		if not (row.get("quantity") is int or row.get("quantity") is float) or row.quantity<1 or row.quantity!=int(row.quantity) or not (row.get("at") is int or row.get("at") is float) or not is_finite(row.at):
			return false
		var result: Dictionary = state.receipts[row.operation_id].result
		if result.get("action")!="buy_seeds" or result.get("items",{}).get(row.crop_id)!=row.quantity:
			return false
		counts[row.event_id] = counts.get(row.event_id,0)+int(row.quantity)
		operations[row.operation_id] = true
	if counts.size()!=state.seasonal.counts.size():
		return false
	for id in counts:
		if state.seasonal.counts.get(id)!=counts[id]:
			return false
	return true
