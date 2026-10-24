extends RefCounted
const Rules = preload("res://scripts/domain/care/care_rules.gd")
const Inventory = preload("res://scripts/domain/farming/inventory.gd")

static func fail(reason: String) -> Dictionary:
	return {"ok":false,"error":reason}

static func execute(next: Dictionary, plot: Dictionary, command: Dictionary, now: float, items: Dictionary) -> Dictionary:
	if plot.crop_id.is_empty():
		return fail("no_crop")
	if command.get("cycle_id","")!=plot.cycle_id:
		return fail("cycle_mismatch")
	var before := Rules.care_view(plot,now)
	var history := {"request_id":command.request_id,"action":command.type,"at":now,"previous_ready_at":plot.ready_at,"source":"owner.local"}
	match command.type:
		"water":
			if not before.needs_water:
				return fail("water_not_needed")
			var settings: Dictionary = plot.care.policy.crops[plot.crop_id]
			if plot.care.water_count>=int(settings.max_water_uses):
				return fail("water_use_limit")
			if plot.care.watered_at!=null and now-float(plot.care.watered_at)<float(settings.water_cooldown):
				return fail("water_cooldown")
			var water: Dictionary = plot.care.policy.water
			var amount := minf(float(plot.base_duration)*float(water.reduction_fraction),maxf(0,float(plot.base_duration)*float(water.max_acceleration)-float(plot.care.water_acceleration)))
			var ready := minf(float(plot.ready_at),Rules.accelerated_ready(plot,now,amount))
			plot.care.water_acceleration += float(plot.ready_at)-ready
			plot.ready_at = ready
			plot.care.watered_at = now
			plot.care.hydrated_until = now+float(settings.hydration_seconds)
			plot.care.water_count += 1
		"remove_weeds", "remove_pests":
			var kind := "weeds" if command.type=="remove_weeds" else "pests"
			if not before[kind]:
				return fail("nuisance_not_present")
			plot.care.nuisances[kind].removed_at = now
		"fertilize":
			if not items.has(command.get("item_id")):
				return fail("unknown_fertilizer")
			var item: Dictionary = items[command.item_id]
			if item.scope!="owner":
				return fail("social_not_available")
			if not item.compatible_crops.has(plot.crop_id):
				return fail("fertilizer_incompatible")
			if now>=float(before.effective_ready_at):
				return fail("not_growing")
			if item.rare and command.get("rare_ack",false)!=true:
				return fail("rare_arm_required")
			var used := 0
			for modifier in plot.modifiers:
				if modifier.item_id==item.id:
					used += 1
			if used>=int(item.max_uses_per_cycle):
				return fail("fertilizer_use_limit")
			var ready := Rules.accelerated_ready(plot,now,(float(before.effective_ready_at)-now)*float(item.reduction_fraction))
			if ready>=float(plot.ready_at):
				return fail("acceleration_limit")
			if not Inventory.consume(next.inventory.fertilizers,item.id,1):
				return fail("no_fertilizer_stock")
			history.item_id = item.id
			plot.ready_at = ready
		_:
			return fail("invalid_tool")
	history.ready_at = plot.ready_at
	plot.care.history.append(history.duplicate(true))
	if command.type=="fertilize":
		plot.modifiers.append(history.duplicate(true))
	var after := Rules.care_view(plot,now)
	return {"ok":true,"action":command.type,"crop_id":plot.crop_id,"cycle_id":plot.cycle_id,"time_saved":float(before.effective_ready_at)-float(after.effective_ready_at),"care_event":history}
