extends RefCounted
## Pure copy migration. Caller must validate source and commit only to a new file.
const OldCatalog = preload("res://scripts/domain/farming/crop_catalog.gd")
const Base = preload("res://scripts/domain/farming/farm_state.gd")
const Care = preload("res://scripts/domain/care/care_state.gd")
const E3 = preload("res://scripts/domain/economy/economy_state.gd")
const L4 = preload("res://scripts/domain/land/land_state.gd")
const Economy = preload("res://scripts/domain/cultures/culture_economy.gd")
const Repeat = preload("res://scripts/domain/cultures/repeat_rules.gd")
const Growth = preload("res://scripts/domain/care/care_rules.gd")

static func read_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

static func source_valid(source: Dictionary) -> bool:
	var catalog := OldCatalog.new()
	var items: Dictionary = {}
	for row in read_json("res://data/farming/g12/fertilizers.json").items:
		items[row.id] = row
	var profile = source.get("clock_profile")
	if not profile is String:
		return false
	if not Base.number(source.get("schema_version")) or source.schema_version!=int(source.schema_version):
		return false
	match int(source.schema_version):
		1: return Base.valid(source,catalog,profile)
		2: return Care.valid(source,catalog,profile,items)
		3: return E3.valid(source,catalog,profile,items,read_json("res://data/farming/g13/economy.json"))
		4: return L4.valid(source,catalog,profile,items,read_json("res://data/farming/g13/economy.json"),read_json("res://data/farming/g14/land.json"))
	return false

static func convert(source: Dictionary, target_profile: String, catalog: RefCounted, policy: Dictionary, items: Dictionary, economy: Dictionary, original_land: Dictionary) -> Dictionary:
	if not source_valid(source):
		return {"ok":false,"error":"invalid_legacy_save"}
	var fast: bool = "fast60" in source.clock_profile
	if fast!=("fast60" in target_profile):
		return {"ok":false,"error":"migration_clock_rate_mismatch"}
	var next := source.duplicate(true)
	var schema: int = int(source.schema_version)
	for receipt in next.receipts.values():
		var fields = JSON.parse_string(receipt.fingerprint)
		if not fields is Array or fields.size() not in [4,6,8,11]:
			return {"ok":false,"error":"unsupported_receipt_format"}
		receipt.original_fingerprint = receipt.fingerprint
		if fields.size()==4:
			fields.append_array(["",false])
		if fields.size()==6:
			fields.append_array([null,[]])
		if fields.size()==8:
			fields.append_array([false,null,null])
		for index in [6,9]:
			if Economy.integer(fields[index]):
				fields[index] = int(fields[index])
		for pair in fields[7]:
			pair[1] = int(pair[1])
		receipt.fingerprint = JSON.stringify(fields)
	var config := economy.duplicate(true)
	config.initial_coins = int(source.economy.ledger[0].quantity) if schema>=3 else 0
	if schema<3:
		# Do not retrospectively grant coins or XP for old harvests.
		var inventory: Dictionary = next.inventory.duplicate(true)
		Economy.initialize(next,config,0)
		next.inventory = inventory
		for receipt in next.receipts.values():
			if receipt.result.get("action")=="harvest":
				receipt.result.xp = 0
	for id in economy.crops:
		if not next.inventory.seeds.has(id):
			next.inventory.seeds[id] = 0
	if not next.inventory.has("fertilizers"):
		next.inventory.fertilizers = {}
	for id in items:
		if not next.inventory.fertilizers.has(id):
			next.inventory.fertilizers[id] = 0
	for id in economy.crops:
		if not next.economy.shop_stock.has(id):
			next.economy.shop_stock[id] = int(economy.crops[id].shop_stock)
	next.economy.unlocks = Economy.unlocked(int(next.economy.level),economy)
	var layout: Dictionary = original_land.duplicate(true)
	if schema<4:
		layout.farm_id = next.farm_id
		layout.owner_id = next.owner_id
		layout.plots = []
		for id in next.plots:
			var plot: Dictionary = next.plots[id]
			var example: Dictionary = original_land.plots.filter(func(row: Dictionary) -> bool: return not row.initial)[0]
			layout.plots.append({"id":id,"grid":plot.grid.duplicate(),"region_id":plot.region_id,"initial":not plot.locked,"price":example.price if plot.locked else 0,"level":example.level if plot.locked else 1,"requires":"","conditions":[],"name":"Terreno preservado "+str(layout.plots.size()+1),"label":str(layout.plots.size()+1)})
		next.land = {"version":layout.version,"history":[]}
	for plot in next.plots.values():
		plot.series = null
		if plot.crop_id.is_empty():
			if schema==1:
				plot.care = Growth.empty_care()
			continue
		if schema==1:
			# Preserve timestamps, add empty care without introducing random incidents.
			Growth.start(plot,policy,func() -> float: return 1)
		else:
			for id in policy.crops:
				if not plot.care.policy.crops.has(id):
					plot.care.policy.crops[id] = policy.crops[id].duplicate(true)
		Repeat.plant(plot,catalog.entries[plot.crop_id])
	next.schema_version = 5
	next.catalog_version = "g15.crops.v1"
	next.clock_profile = target_profile
	next.genesis_coins = config.initial_coins
	next.layout = layout
	next.seasonal = {"counts":{},"acquisitions":[]}
	next.migration = {"source_schema":schema,"source_profile":source.clock_profile,"source_catalog":source.catalog_version,"source_revision":source.revision,"source_sha256":JSON.stringify(source).sha256_text(),"policy":"COPY_ONLY_NO_RETROACTIVE_REWARDS"}
	return {"ok":true,"state":next}
