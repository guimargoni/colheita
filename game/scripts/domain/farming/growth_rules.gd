extends RefCounted
## Stateless derivation: no delta, countdown accumulation or frame dependency.

static func view(plot: Dictionary, crop: Dictionary, now: float) -> Dictionary:
	if plot.locked:
		return {"state":"locked","stage":0,"remaining":0.0,"progress":0.0}
	if plot.crop_id.is_empty():
		return {"state":"empty","stage":0,"remaining":0.0,"progress":0.0}
	var duration := maxf(0.001,float(plot.ready_at)-float(plot.planted_at))
	var progress := clampf((now-float(plot.planted_at))/duration,0,1)
	var stage := 0
	for i in range(crop.stages.size()):
		if progress>=float(crop.stages[i].at):
			stage = i
	return {"state":"mature" if now>=float(plot.ready_at) else "planted" if stage==0 else "growing","stage":stage,"progress":progress,"remaining":maxf(0,float(plot.ready_at)-now)}

static func preview_fertilizer(plot: Dictionary, crop: Dictionary, item: Dictionary, limits: Dictionary, now: float, request_id: String, actor_scope: String) -> Dictionary:
	# Pure preparation only. Runtime service does NOT expose applying these items.
	if plot.crop_id.is_empty() or now>=float(plot.ready_at):
		return {"ok":false,"error":"not_growing"}
	if not crop.fertilizers.has(item.get("id")) or item.get("scope")!=actor_scope:
		return {"ok":false,"error":"incompatible"}
	for record in plot.modifiers:
		if record.request_id==request_id:
			return {"ok":false,"error":"duplicate_modifier"}
	for key in ["max_total_acceleration","minimum_growth_seconds","max_uses_per_cycle"]:
		if limits.get(key)==null:
			return {"ok":false,"error":"not_balanced"}
	if item.get("reduction_fraction")==null:
		return {"ok":false,"error":"not_balanced"}
	var fraction := float(item.reduction_fraction)
	var cap := float(limits.max_total_acceleration)
	if not is_finite(fraction) or not is_finite(cap) or fraction<=0 or fraction>=1 or cap<=0 or cap>=1 or limits.minimum_growth_seconds<=0 or limits.max_uses_per_cycle<1:
		return {"ok":false,"error":"invalid_limits"}
	if plot.modifiers.size()>=int(limits.max_uses_per_cycle):
		return {"ok":false,"error":"use_limit"}
	var duration := float(plot.base_duration)
	var earliest := maxf(float(plot.planted_at)+maxf(float(limits.minimum_growth_seconds),duration*(1-cap)),now+float(limits.minimum_growth_seconds))
	var ready := maxf(earliest,float(plot.ready_at)-duration*fraction)
	if ready>=float(plot.ready_at):
		return {"ok":false,"error":"acceleration_limit"}
	return {"ok":true,"ready_at":ready,"history":{"request_id":request_id,"item_id":item.id,"applied_at":now,"previous_ready_at":plot.ready_at,"ready_at":ready,"scope":actor_scope}}
