extends "res://scripts/domain/farming/crop_catalog.gd"

func valid(crop: Dictionary) -> bool:
	if not super.valid(crop) or crop.get("category") not in ["vegetable","fruit","cereal","flower","tree","special"]:
		return false
	if not (crop.get("harvest_count") is float or crop.get("harvest_count") is int) or crop.harvest_count!=int(crop.harvest_count) or crop.harvest_count<1 or crop.harvest_count>16:
		return false
	if not (crop.get("regrowth_seconds") is float or crop.get("regrowth_seconds") is int) or not is_finite(crop.regrowth_seconds) or crop.regrowth_seconds<0:
		return false
	if crop.harvest_count>1:
		var copy := crop.duplicate(true)
		copy.stages = crop.get("regrowth_stages")
		if crop.regrowth_seconds<=0 or not super.valid(copy):
			return false
	return true
