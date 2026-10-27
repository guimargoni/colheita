extends "res://scripts/services/integrated/farm_service.gd"
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
const Gateway = preload("res://scripts/services/integrated/local_gateway.gd")
var gateway: RefCounted
var player: Dictionary = {}
var poll_thread: Thread
var anchor: float = 0
var tick_anchor: int = 0
var refresh_at: int = 0
func _init(profile: String = "one", port: int = 16661) -> void:
	super(Clock.new(),null)
	authority = "LOCAL_SERVER_AUTHORITATIVE"
	if profile not in ["one","two"]: error = "unknown_local_profile"; return
	var config := ConfigFile.new()
	var path := "user://integrated_identity_"+profile+".cfg"
	var loaded: int = config.load(path)
	var token: String = config.get_value("identity","credential","") if loaded==OK else ""
	if token.is_empty():
		token = Crypto.new().generate_random_bytes(32).hex_encode()
		config.set_value("identity","credential",token)
		if config.save(path)!=OK: error = "identity_save_failed"; return
	gateway = Gateway.new(token,port)
	var response: Dictionary = gateway.request("register",{"name":"Fazendeiro 1" if profile=="one" else "Fazendeiro 2"})
	apply_reply(response)
func calendar() -> float:
	return anchor+float(Time.get_ticks_msec()-tick_anchor)/1000.0
func apply_reply(reply: Dictionary) -> void:
	if not reply.get("ok",false): error = str(reply.get("error","network_error")); return
	if reply.has("state"):
		state = reply.state
		land_config = state.layout
		economy_config.initial_coins = state.genesis_coins
		clock.rate = float(reply.get("rate",clock.rate))
		anchor = float(reply.get("server_now",0))/clock.rate
		tick_anchor = Time.get_ticks_msec()
		clock.source = calendar
		error = ""
	if reply.has("player"): player = reply.player
func execute(command: Dictionary) -> Dictionary:
	if gateway==null: return fail(error)
	if poll_thread!=null and poll_thread.is_started():
		apply_reply(poll_thread.wait_to_finish()); poll_thread = null
	var args := command.duplicate(true)
	var operation: String = args.get("request_id","")
	args.erase("request_id")
	var result: Dictionary = gateway.request("farm_command",args,operation)
	if result.ok:
		if not result.has("state"): apply_reply(gateway.request("snapshot"))
		else: apply_reply(result)
	else:
		if result.get("error","").begins_with("server_"): error = result.error
	return result
func poll() -> void:
	if gateway==null: return
	if poll_thread!=null and poll_thread.is_started():
		if poll_thread.is_alive(): return
		apply_reply(poll_thread.wait_to_finish()); poll_thread = null
	if Time.get_ticks_msec()>=refresh_at:
		refresh_at = Time.get_ticks_msec()+1500
		poll_thread = Thread.new()
		poll_thread.start(func() -> Dictionary: return gateway.request("snapshot"))
func social(method: String, args: Dictionary = {}) -> Dictionary:
	return gateway.request(method,args) if gateway!=null else fail(error)
func shutdown() -> void:
	if poll_thread!=null and poll_thread.is_started(): poll_thread.wait_to_finish()
	poll_thread = null
	clock.source = Callable()
