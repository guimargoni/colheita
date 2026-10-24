extends RefCounted

var entries: Dictionary = {}
var ids: Array[String] = []
var error: String = ""

func _init(path: String = "res://data/farming/crops.json") -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary or data.get("schema_version")!=1 or not data.get("crops") is Array:
		error = "invalid_catalog"
		return
	for crop in data.crops:
		if not crop is Dictionary or not valid(crop) or entries.has(crop.id):
			error = "invalid_crop"
			entries.clear()
			ids.clear()
			return
		entries[crop.id] = crop
		ids.append(crop.id)

func valid(crop: Dictionary) -> bool:
	for key in ["id","name","growth_seconds","yield_quantity","seed_price","sell_value","xp","unlock_level","care","fertilizers","stages","art"]:
		if not crop.has(key):
			return false
	if not crop.id is String or not crop.name is String or crop.id.is_empty() or crop.name.is_empty():
		return false
	for key in ["growth_seconds","yield_quantity","seed_price","sell_value","xp","unlock_level"]:
		if not (crop[key] is float or crop[key] is int) or not is_finite(float(crop[key])) or crop[key]<0:
			return false
	if crop.growth_seconds<=0 or crop.yield_quantity<1 or crop.yield_quantity!=int(crop.yield_quantity):
		return false
	if not crop.stages is Array or crop.stages.size()<2 or not crop.care is Dictionary or not crop.fertilizers is Array or not crop.art is Dictionary:
		return false
	var previous := -1.0
	for stage in crop.stages:
		if not stage is Dictionary or not stage.get("key") is String or not (stage.get("at") is float or stage.get("at") is int):
			return false
		if not is_finite(float(stage.at)) or stage.at<=previous or stage.at<0 or stage.at>1:
			return false
		previous = stage.at
	return crop.stages[0].at==0 and crop.stages[-1].at==1
