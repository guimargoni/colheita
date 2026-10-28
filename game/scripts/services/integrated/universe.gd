extends RefCounted
## Single-writer authoritative development world. Never load client snapshots.
const Farm = preload("res://scripts/services/integrated/farm_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var social_config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/integrated/social.json"))
var community: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/integrated/community.json"))
var data: Dictionary
var work: Dictionary
var path: String
var rate: float = 1
var error: String = ""
class AccountStore extends RefCounted:
	var owner: RefCounted
	var player: String
	var error: String = ""
	func _init(universe: RefCounted, id: String) -> void: owner = universe; player = id
	func read() -> Dictionary:
		return {"ok":true,"missing":false,"state":owner.work.farms[player].duplicate(true)} if owner.work.farms.has(player) else {"ok":true,"missing":true}
	func commit(state: Dictionary, expected: int) -> bool:
		var previous: Dictionary = owner.work.farms.get(player,{})
		if int(previous.get("revision",-1))!=expected: error = "revision_conflict"; return false
		owner.work.farms[player] = state.duplicate(true)
		return true
func _init(file: String, multiplier: float = 1) -> void:
	path = file; rate = multiplier
	data = {"version":1,"rate":rate,"accounts":{},"tokens":{},"farms":{},"friends":{},"requests":{},"invites":{},"blocks":{},"permissions":{},"popularity":{},"activity":[],"receipts":{},"limits":{}}
	if FileAccess.file_exists(path):
		var loaded = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not loaded is Dictionary or loaded.get("version")!=1 or loaded.get("rate")!=rate: error = "server_store_or_rate_invalid"
		else:
			for key in ["accounts","tokens","farms","friends","requests","invites","blocks","permissions","popularity","receipts","limits"]:
				if not loaded.get(key) is Dictionary: error = "server_store_invalid"; return
			if not loaded.get("activity") is Array: error = "server_store_invalid"; return
			data = loaded
func persist() -> bool:
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file==null: error = "server_write_failed"; return false
	file.store_string(JSON.stringify(work))
	file.flush()
	var code := file.get_error(); file.close()
	if code!=OK or DirAccess.rename_absolute(ProjectSettings.globalize_path(path+".tmp"),ProjectSettings.globalize_path(path))!=OK: error = "server_commit_failed"; return false
	data = work.duplicate(true)
	return true
func farm(id: String) -> RefCounted:
	var service := Farm.new(Clock.new(Callable(),rate,"server.integrated.fast60.v1" if rate>1 else "server.integrated.real.v1"),AccountStore.new(self,id))
	service.land_config = service.land_config.duplicate(true)
	service.land_config.farm_id = "farm."+id
	service.land_config.owner_id = id
	service.load_farm(service.fixture())
	return service
func denied(reason: String) -> Dictionary: return {"ok":false,"error":reason}
func now() -> float: return Time.get_unix_time_from_system()*rate
func peer_allowed(a: String,b: String) -> bool:
	return a!=b and work.accounts.has(b) and not work.blocks.get(a,[]).has(b) and not work.blocks.get(b,[]).has(a)
func can_visit(a: String,b: String) -> bool:
	return peer_allowed(a,b) and work.friends.get(a,[]).has(b) and work.permissions[b].visits
func cap(key: String, amount: int, maximum: int) -> bool:
	var day: String = str(int(Time.get_unix_time_from_system()/86400))
	var id: String = day+"/"+key
	var previous: int = int(work.limits.get(id,0))
	if previous+amount>maximum: return false
	work.limits[id] = previous+amount
	return true
func activity(actor: String,target: String,action: String,detail: String) -> void:
	work.activity.append({"actor":actor,"target":target,"action":action,"detail":detail,"at":Time.get_unix_time_from_system()})
	if work.activity.size()>500: work.activity.pop_front()
func owner_reply(id: String) -> Dictionary:
	var own := farm(id)
	if not own.error.is_empty(): return denied(own.error)
	return {"ok":true,"player":work.accounts[id],"state":own.state,"server_now":now(),"calendar_now":Time.get_unix_time_from_system(),"rate":rate}
func handle(request: Dictionary) -> Dictionary:
	if not error.is_empty(): return denied(error)
	if not request.get("method") is String or not request.get("token") is String or request.token.length()!=64 or not request.token.is_valid_hex_number(false): return denied("invalid_authentication")
	if not request.get("args",{}) is Dictionary: return denied("invalid_arguments")
	work = data.duplicate(true)
	if not work.has("community"): work.community = {"total":0,"contributors":{},"claimed":[]}
	if not work.has("last_theft"): work.last_theft = {}
	var token_hash: String = request.token.sha256_text()
	var actor: String = work.tokens.get(token_hash,"")
	if request.method=="register":
		if not actor.is_empty(): return owner_reply(actor)
		var name: Variant = request.get("args",{}).get("name","")
		if not name is String or name.strip_edges().length()<2 or name.length()>24 or "\n" in name or "\r" in name: return denied("invalid_display_name")
		if not cap("registration",1,100): return denied("registration_limit")
		actor = Crypto.new().generate_random_bytes(12).hex_encode()
		work.accounts[actor] = {"id":actor,"name":name.strip_edges()}
		work.tokens[token_hash] = actor
		work.friends[actor] = []; work.blocks[actor] = []; work.permissions[actor] = {"visits":true,"mischief":false}; work.popularity[actor] = 0
		var own := farm(actor)
		if not own.error.is_empty(): return denied(own.error)
		if not persist(): return denied(error)
		return owner_reply(actor)
	if actor.is_empty(): return denied("unauthorized")
	var args: Variant = request.get("args",{})
	if not args is Dictionary: return denied("invalid_arguments")
	if request.method=="snapshot": return owner_reply(actor)
	if request.method=="social_state":
		var requests: Array = []
		for id in work.requests:
			var row: Dictionary = work.requests[id]
			if row.to==actor or row.from==actor: requests.append({"id":id,"from":work.accounts[row.from],"to":work.accounts[row.to]})
		var friends: Array = []
		for id in work.friends[actor]: friends.append(work.accounts[id])
		var blocks: Array = []
		for id in work.blocks[actor]: blocks.append(work.accounts[id])
		var invites: Array = []
		for code in work.invites:
			if work.invites[code].owner==actor: invites.append({"code":code,"revoked":work.invites[code].revoked,"expires":work.invites[code].expires})
		return {"ok":true,"player":work.accounts[actor],"friends":friends,"requests":requests,"blocks":blocks,"invites":invites,"permissions":work.permissions[actor],"popularity":work.popularity[actor],"activity":visible_activity(actor)}
	if request.method=="community_state": return {"ok":true,"config":community,"progress":work.community}
	if request.method=="discover":
		var query: Variant = args.get("query","")
		if not query is String or query.length()<2 or query.length()>24: return denied("query_too_short")
		var found: Array = []
		for id in work.accounts:
			if peer_allowed(actor,id) and (query.to_lower() in work.accounts[id].name.to_lower() or query==id): found.append(work.accounts[id])
		return {"ok":true,"players":found.slice(0,20)}
	if request.method=="visit":
		var target: Variant = args.get("target","")
		if not target is String or not can_visit(actor,target): return denied("visit_denied")
		var other := farm(target)
		var snapshot: Dictionary = other.snapshot()
		# No target token, receipts, wallet ledger or private inventory is exposed.
		return {"ok":true,"player":work.accounts[target],"plots":snapshot.plots,"features":snapshot.features,"level":snapshot.economy.level,"server_now":now()}
	var operation: Variant = request.get("request_id")
	if not operation is String or operation.is_empty() or operation.length()>128: return denied("invalid_request_id")
	var key: String = actor+"/"+operation
	var fingerprint := JSON.stringify([request.method,args])
	if work.receipts.has(key):
		var receipt: Dictionary = work.receipts[key]
		if receipt.fingerprint!=fingerprint: return denied("idempotency_conflict")
		var replay: Dictionary = receipt.result.duplicate(true); replay.replayed = true; return replay
	if not cap(actor+"/operations",1,5000): return denied("daily_operation_limit")
	var result: Dictionary
	if request.method=="farm_command":
		var own := farm(actor)
		var command: Dictionary = args.duplicate(true)
		command.actor_id = actor; command.request_id = "owner/"+operation
		result = own.execute(command)
	else:
		result = social(actor,request.method,args)
	if not result.ok: return result
	work.receipts[key] = {"fingerprint":fingerprint,"result":result.duplicate(true)}
	if not persist(): return denied(error)
	if request.method=="farm_command":
		result.state = work.farms[actor].duplicate(true); result.server_now = now(); result.rate = rate
	return result
func social(actor: String, method: String,args: Dictionary) -> Dictionary:
	var target: Variant = args.get("target","")
	if not target is String: return denied("invalid_target")
	match method:
		"invite_create":
			var code := Crypto.new().generate_random_bytes(16).hex_encode()
			work.invites[code] = {"owner":actor,"expires":Time.get_unix_time_from_system()+float(social_config.invite_lifetime_seconds),"revoked":false}
			return {"ok":true,"code":code,"link":"colheita://invite/"+code}
		"invite_revoke":
			var code: Variant = args.get("code","")
			if not code is String or not work.invites.has(code) or work.invites[code].owner!=actor: return denied("unknown_invite")
			work.invites[code].revoked = true
		"invite_redeem":
			var code: Variant = args.get("code","")
			if not code is String: return denied("invalid_invite")
			code = code.trim_prefix("colheita://invite/")
			if code.begins_with("http://") or code.begins_with("https://"): code = code.trim_suffix("/").get_slice("/",code.trim_suffix("/").get_slice_count("/")-1)
			if not work.invites.has(code) or work.invites[code].revoked or work.invites[code].expires<Time.get_unix_time_from_system(): return denied("invite_expired_or_revoked")
			target = work.invites[code].owner
			if not peer_allowed(actor,target): return denied("interaction_denied")
			if work.friends[actor].has(target): return denied("already_friends")
			if work.requests.has(actor+"/"+target): return denied("request_pending")
			if not cap(actor+"/friend_requests",1,20): return denied("friend_request_limit")
			work.requests[actor+"/"+target] = {"from":actor,"to":target}
		"friend_request":
			if not peer_allowed(actor,target) or work.friends[actor].has(target): return denied("interaction_denied")
			if work.requests.has(actor+"/"+target): return denied("request_pending")
			if not cap(actor+"/friend_requests",1,20): return denied("friend_request_limit")
			work.requests[actor+"/"+target] = {"from":actor,"to":target}
		"friend_cancel":
			if not work.requests.has(actor+"/"+target): return denied("request_unavailable")
			work.requests.erase(actor+"/"+target)
		"friend_accept","friend_reject":
			var id: String = target+"/"+actor
			if not peer_allowed(actor,target) or not work.requests.has(id): return denied("request_unavailable")
			if method=="friend_accept":
				if not work.friends[actor].has(target): work.friends[actor].append(target)
				if not work.friends[target].has(actor): work.friends[target].append(actor)
			work.requests.erase(id)
		"block":
			if not work.accounts.has(target) or actor==target: return denied("invalid_target")
			if not work.blocks[actor].has(target): work.blocks[actor].append(target)
			work.friends[actor].erase(target); work.friends[target].erase(actor)
			work.requests.erase(actor+"/"+target); work.requests.erase(target+"/"+actor)
		"unblock": work.blocks[actor].erase(target)
		"permissions":
			if not args.get("visits") is bool or not args.get("mischief") is bool: return denied("invalid_permissions")
			work.permissions[actor] = {"visits":args.visits,"mischief":args.mischief}
		"gift","help","steal","mischief","animal_help":
			if not can_visit(actor,target): return denied("interaction_denied")
			return farm_social(actor,target,method,args)
		"community_donate":
			var amount: Variant = args.get("quantity",1)
			if not Farm.Economy.integer(amount,10) or amount<1: return denied("invalid_quantity")
			var calendar: float = Time.get_unix_time_from_system()
			if calendar<Time.get_unix_time_from_datetime_string(community.starts_at) or calendar>=Time.get_unix_time_from_datetime_string(community.ends_at): return denied("event_closed")
			var own := farm(actor)
			if own.state.inventory.products.get(community.donation_product,0)<amount or work.community.contributors.get(actor,0)+amount>community.max_per_player: return denied("donation_stock_or_limit")
			own.state.inventory.products[community.donation_product] -= int(amount)
			own.state.revision += 1; work.farms[actor] = own.state
			work.community.total += int(amount)
			work.community.contributors[actor] = int(work.community.contributors.get(actor,0))+int(amount)
		"community_claim":
			if work.community.total<community.goal or work.community.contributors.get(actor,0)<1 or actor in work.community.claimed: return denied("community_reward_unavailable")
			var own := farm(actor)
			own.state.inventory.seeds[community.reward_seed] = int(own.state.inventory.seeds.get(community.reward_seed,0))+int(community.reward_quantity)
			own.state.revision += 1; work.farms[actor] = own.state
			work.community.claimed.append(actor)
		_: return denied("unknown_method")
	activity(actor,target,method,"")
	return {"ok":true,"action":method}
func farm_social(actor: String,target: String,method: String,args: Dictionary) -> Dictionary:
	var own := farm(actor)
	var other := farm(target)
	if method=="gift":
		var product: Variant = args.get("product","crop.rose")
		if product not in ["crop.rose","bouquet","egg","honey","milk","wool"] or not cap(actor+"/gift/"+target,1,int(social_config.gifts_per_pair_per_day)): return denied("gift_limit_or_item")
		var source: Dictionary = own.state.inventory.products if product=="crop.rose" else own.state.features.goods
		var destination: Dictionary = other.state.inventory.products if product=="crop.rose" else other.state.features.goods
		if source.get(product,0)<1 or destination.get(product,0)>=1000000: return denied("gift_stock")
		source[product] -= 1; destination[product] = int(destination.get(product,0))+1
		work.popularity[target] += 5 if product=="bouquet" else 1
		own.state.revision += 1; other.state.revision += 1
		work.farms[actor] = own.state; work.farms[target] = other.state
		activity(actor,target,method,product)
		return {"ok":true,"action":"gift","product":product}
	if method=="animal_help":
		var id: Variant = args.get("id","")
		if not id is String or not other.state.features.producers.has(id): return denied("unknown_producer")
		var p: Dictionary = other.state.features.producers[id]
		var needed: int = int(other.features_config.producers[p.kind].feed)
		if own.state.features.feed<needed or p.ready_at>0 or not cap(actor+"/animal_help",1,int(social_config.animal_helps_per_day)): return denied("animal_help_unavailable")
		own.state.features.feed -= needed
		other.state.features.feed += needed
		var result: Dictionary = other.execute({"type":"producer_feed","id":id,"request_id":"social.feed/"+Crypto.new().generate_random_bytes(16).hex_encode()})
		if not result.ok: return result
		own.state.revision += 1; work.farms[actor] = own.state
		activity(actor,target,method,p.kind)
		return {"ok":true,"action":"animal_help"}
	var plot_id: Variant = args.get("plot_id","")
	if not plot_id is String or not other.state.plots.has(plot_id): return denied("unknown_plot")
	var plot: Dictionary = other.state.plots[plot_id]
	if plot.crop_id.is_empty() or plot.locked: return denied("no_crop")
	var cycle_key: String = actor+"/"+target+"/"+plot.cycle_id
	if method=="help":
		var action: Variant = args.get("action","water")
		if action not in ["water","remove_weeds","remove_pests"] or not cap(cycle_key+"/help/"+action,1,1) or not cap(actor+"/help",1,int(social_config.helps_per_day)): return denied("help_limit")
		var result: Dictionary = other.execute({"type":action,"plot_id":plot_id,"cycle_id":plot.cycle_id,"request_id":"social/"+Crypto.new().generate_random_bytes(16).hex_encode()})
		if not result.ok: return result
		work.popularity[actor] += 1
		activity(actor,target,"help",action)
		return {"ok":true,"action":"help"}
	if method=="mischief":
		if not work.permissions[target].mischief or not cap(cycle_key+"/mischief",1,1) or not cap(actor+"/mischief",1,int(social_config.mischief_per_day)): return denied("mischief_denied")
		var kind: Variant = args.get("kind","weeds")
		if kind not in ["weeds","pests"]: return denied("invalid_nuisance")
		if plot.care.nuisances[kind].removed_at!=null or plot.care.nuisances[kind].appears_at!=null: return denied("nuisance_already_scheduled")
		plot.care.nuisances[kind].appears_at = now()
		other.state.revision += 1; work.farms[target] = other.state
		activity(actor,target,"mischief",kind)
		return {"ok":true,"action":"mischief"}
	if other.state.economy.level<int(social_config.minimum_theft_target_level): return denied("beginner_protected")
	var crop: Dictionary = other.catalog.entries[plot.crop_id]
	if other.Repeat.view(plot,crop,now()).state!="mature": return denied("not_mature")
	if now()-float(work.last_theft.get(actor,0))<float(social_config.theft_cooldown_seconds): return denied("theft_cooldown")
	if other.state.features.guardian.fed_until>now():
		work.last_theft[actor] = now()
		activity(actor,target,"guardian_blocked",plot_id)
		return {"ok":true,"action":"guardian_blocked"}
	var maximum: int = mini(int(crop.yield_quantity)-int(social_config.protected_minimum),maxi(1,int(floor(crop.yield_quantity*float(social_config.max_theft_fraction)))))
	if plot.social.theft_taken>=maximum or not cap(cycle_key+"/steal",1,1) or not cap(actor+"/steal/"+target,1,int(social_config.thefts_per_pair_per_day)): return denied("theft_limit")
	if own.state.inventory.products.get(crop.id,0)>=1000000: return denied("capacity")
	work.last_theft[actor] = now()
	plot.social.theft_taken += 1
	own.state.inventory.products[crop.id] = int(own.state.inventory.products.get(crop.id,0))+1
	own.state.revision += 1; other.state.revision += 1
	work.farms[actor] = own.state; work.farms[target] = other.state
	activity(actor,target,"steal",crop.id)
	return {"ok":true,"action":"steal","quantity":1,"protected_minimum":1}

func visible_activity(actor: String) -> Array:
	var rows: Array = []
	for row in work.activity:
		if row.actor==actor or row.target==actor:
			var copy: Dictionary = row.duplicate(true)
			copy.actor_name = work.accounts.get(row.actor,{}).get("name","Fazendeiro")
			copy.target_name = work.accounts.get(row.target,{}).get("name","")
			rows.append(copy)
	return rows
