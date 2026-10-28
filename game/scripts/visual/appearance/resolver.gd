extends RefCounted
## Presentation only. No service, inventory, clock authority or image paths in saves.
signal changed
var pack: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/visual/v2/appearance.json"))
var theme: String = "standard"
var skins: Dictionary = {}
var textures: Dictionary = {}
var fallbacks: Array[String] = []
func set_theme(id: String) -> bool:
	if not pack.themes.has(id): return false
	theme = id; changed.emit(); return true
func set_skin(entity: String,id: String) -> bool:
	if id.is_empty(): skins.erase(entity); changed.emit(); return true
	if not pack.skins.has(id) or pack.skins[id].entity!=entity: return false
	skins[entity] = id; changed.emit(); return true
func palette(key: String) -> Color: return Color(pack.themes[theme][key])
func resolve(entity: String,base: String,functional: String = "idle",animation: String = "idle",variation: int = 0) -> Dictionary:
	var key: String = pack.themes[theme].overrides.get(base,base)
	if skins.has(entity): key = pack.skins[skins[entity]].asset
	if pack.assets.has(key):
		var binding: Dictionary = pack.assets[key]
		key = binding.get("states",{}).get(functional,key)
		if pack.assets.has(key): key = pack.assets[key].get("animations",{}).get(animation,key)
		if pack.assets.has(key):
			var variants: Array = pack.assets[key].get("variants",[])
			if not variants.is_empty(): key = variants[posmod(variation,variants.size())]
	var visited: Dictionary = {}
	while pack.assets.has(key) and not visited.has(key):
		visited[key] = true
		var entry: Dictionary = pack.assets[key]
		if ResourceLoader.exists(entry.texture):
			var result := entry.duplicate(true)
			result.key = key; result.functional = functional; result.animation = animation; result.variation = variation
			return result
		fallbacks.append(key); key = entry.fallback
	# Unknown seasonal/individual asset uses the known base, never another arbitrary family.
	if key!=base and pack.assets.has(base) and ResourceLoader.exists(pack.assets[base].texture):
		var result: Dictionary = pack.assets[base].duplicate(true); result.key = base; return result
	fallbacks.append(base); return {}
func texture(entry: Dictionary) -> Texture2D:
	var path: String = entry.texture
	if not textures.has(path): textures[path] = load(path)
	return textures[path]
func preview(base: String,entity: String = "") -> Texture2D:
	var entry := resolve(entity,base)
	if entry.is_empty(): return null
	var result := AtlasTexture.new(); result.atlas = texture(entry)
	var r: Array = entry.rect; result.region = Rect2(r[0],r[1],r[2],r[3]); return result
