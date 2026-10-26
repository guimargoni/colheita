extends RefCounted
const Care = preload("res://scripts/domain/care/care_rules.gd")

static func plant(plot: Dictionary, crop: Dictionary) -> void:
	plot.series = {"id":plot.cycle_id,"total":int(crop.harvest_count),"completed":0,"regrowth_seconds":float(crop.regrowth_seconds),"regrowth_stages":crop.get("regrowth_stages",[]).duplicate(true)}

static func view(plot: Dictionary, crop: Dictionary, now: float) -> Dictionary:
	var effective := crop.duplicate(true)
	if not plot.crop_id.is_empty() and plot.series.completed>0:
		effective.stages = plot.series.regrowth_stages
	var result := Care.view(plot,effective,now)
	result.regrowing = not plot.crop_id.is_empty() and plot.series.completed>0
	result.harvests_remaining = int(plot.series.total-plot.series.completed) if not plot.crop_id.is_empty() else 0
	return result

static func after_harvest(next: Dictionary, plot: Dictionary, now: float, roll: Callable, result: Dictionary) -> void:
	plot.series.completed += 1
	result.harvest_index = plot.series.completed
	result.harvests_remaining = plot.series.total-plot.series.completed
	result.series_id = plot.series.id
	if plot.series.completed<plot.series.total:
		var policy: Dictionary = plot.care.policy.duplicate(true)
		plot.cycle_id = next.farm_id+"/cycle/"+str(int(next.next_cycle))
		next.next_cycle += 1
		plot.planted_at = now
		plot.base_duration = plot.series.regrowth_seconds
		plot.ready_at = now+float(plot.base_duration)
		plot.modifiers = []
		Care.start(plot,policy,roll)
		result.next_cycle_id = plot.cycle_id
	else:
		plot.crop_id = ""
		plot.cycle_id = ""
		plot.cultivation_state = "empty"
		plot.planted_at = null
		plot.ready_at = null
		plot.base_duration = null
		plot.care = Care.empty_care()
		plot.modifiers = []
		plot.series = null

static func valid(plot: Dictionary) -> bool:
	if plot.crop_id.is_empty():
		return plot.get("series")==null
	var series = plot.get("series")
	if not series is Dictionary or not series.get("id") is String or series.id.is_empty():
		return false
	for key in ["total","completed"]:
		if not (series.get(key) is int or series.get(key) is float) or not is_finite(series[key]) or series[key]!=int(series[key]):
			return false
	if series.total<1 or series.total>16 or series.completed<0 or series.completed>=series.total or not (series.get("regrowth_seconds") is float or series.get("regrowth_seconds") is int) or not is_finite(series.regrowth_seconds) or not series.get("regrowth_stages") is Array:
		return false
	if series.total>1:
		if series.regrowth_seconds<=0 or series.regrowth_stages.size()<2:
			return false
		var previous: float = -1
		for stage in series.regrowth_stages:
			if not stage is Dictionary or not stage.get("key") is String or not (stage.get("at") is int or stage.get("at") is float) or not is_finite(stage.at) or stage.at<=previous or stage.at<0 or stage.at>1:
				return false
			previous = stage.at
		if series.regrowth_stages[0].at!=0 or previous!=1:
			return false
	return true
