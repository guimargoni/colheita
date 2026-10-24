extends RefCounted
const Growth = preload("res://scripts/domain/farming/growth_rules.gd")

static func empty_care() -> Dictionary:
	return {"watered_at":null,"hydrated_until":null,"water_count":0,"water_acceleration":0.0,"history":[],"nuisances":{},"policy":{}}

static func start(plot: Dictionary, policy: Dictionary, roll: Callable) -> void:
	plot.care = empty_care()
	plot.care.policy = policy.duplicate(true)
	for kind in policy.nuisances:
		var rule: Dictionary = policy.nuisances[kind]
		plot.care.nuisances[kind] = {"appears_at":float(plot.planted_at)+float(plot.base_duration)*float(rule.at_fraction) if float(roll.call())<float(rule.probability) else null,"removed_at":null,"source":"ambient.local"}

static func care_view(plot: Dictionary, now: float) -> Dictionary:
	var result := {"hydrated":false,"needs_water":false,"weeds":false,"pests":false,"delay_seconds":0.0,"effective_ready_at":plot.ready_at}
	if plot.crop_id.is_empty():
		return result
	var care: Dictionary = plot.care
	result.hydrated = care.hydrated_until!=null and now<float(care.hydrated_until)
	var penalty := 0.0
	for kind in care.nuisances:
		var nuisance: Dictionary = care.nuisances[kind]
		result[kind] = nuisance.appears_at!=null and now>=float(nuisance.appears_at) and nuisance.removed_at==null
		if result[kind]:
			penalty += float(care.policy.nuisances[kind].delay_fraction)
	result.delay_seconds = float(plot.base_duration)*minf(penalty,float(care.policy.max_nuisance_delay))
	result.effective_ready_at = float(plot.ready_at)+float(result.delay_seconds)
	result.needs_water = not result.hydrated and now<float(result.effective_ready_at)
	return result

static func view(plot: Dictionary, crop: Dictionary, now: float) -> Dictionary:
	var adjusted := plot.duplicate(true)
	var care := care_view(plot,now)
	if not plot.crop_id.is_empty():
		adjusted.ready_at = care.effective_ready_at
	var result := Growth.view(adjusted,crop,now)
	result.care = care
	return result

static func accelerated_ready(plot: Dictionary, now: float, reduction: float) -> float:
	var limits: Dictionary = plot.care.policy.acceleration
	var earliest := maxf(float(plot.planted_at)+float(plot.base_duration)*(1-float(limits.max_total_fraction)),now+float(limits.minimum_remaining_seconds))
	return maxf(earliest,float(plot.ready_at)-maxf(0,reduction))

static func valid_policy(policy: Dictionary, catalog: RefCounted) -> bool:
	if not policy.get("water") is Dictionary or not policy.get("acceleration") is Dictionary or not policy.get("nuisances") is Dictionary or not policy.get("crops") is Dictionary:
		return false
	var cap = policy.acceleration.get("max_total_fraction")
	if not (cap is float or cap is int) or cap<=0 or cap>=1 or policy.acceleration.get("minimum_remaining_seconds",0)<=0:
		return false
	if policy.water.get("reduction_fraction",0)<=0 or policy.water.get("max_acceleration",0)<=0 or policy.get("max_nuisance_delay",-1)<0:
		return false
	for kind in ["weeds","pests"]:
		if not policy.nuisances.get(kind) is Dictionary:
			return false
		var rule: Dictionary = policy.nuisances[kind]
		if rule.get("probability",-1)<0 or rule.probability>1 or rule.get("at_fraction",-1)<0 or rule.at_fraction>=1-cap or rule.get("delay_fraction",-1)<0:
			return false
	for id in catalog.ids:
		if not policy.crops.get(id) is Dictionary:
			return false
		var crop: Dictionary = policy.crops[id]
		if crop.get("hydration_seconds",0)<=0 or crop.get("water_cooldown",0)<=0 or crop.get("max_water_uses",0)<1:
			return false
	return true
