extends SceneTree
const Universe = preload("res://scripts/services/integrated/universe.gd")
var listener := TCPServer.new()
var peers: Array[Dictionary] = []
var universe: RefCounted
var port: int = 16661
func _initialize() -> void:
	var file := ProjectSettings.globalize_path("res://../.local/backend/world.json")
	var rate: float = 1
	for arg in OS.get_cmdline_user_args():
		if arg=="--fast": rate = 60
		if arg.begins_with("--port="): port = arg.trim_prefix("--port=").to_int()
		if arg.begins_with("--world="): file = arg.trim_prefix("--world=")
	DirAccess.make_dir_recursive_absolute(file.get_base_dir())
	universe = Universe.new(file,rate)
	if not universe.error.is_empty(): push_error(universe.error); quit(1); return
	if port<1024 or port>65535 or listener.listen(port,"127.0.0.1")!=OK: push_error("server_listen_failed"); quit(1); return
	print("COLHEITA_LOCAL_SERVER_READY loopback port=%d rate=%.0f"%[port,rate])
func _process(_delta: float) -> bool:
	while listener.is_connection_available():
		var socket := listener.take_connection()
		if peers.size()>=24: socket.disconnect_from_host()
		else: peers.append({"socket":socket,"text":"","started":Time.get_ticks_msec(),"done":false})
	for peer in peers:
		var socket: StreamPeerTCP = peer.socket
		socket.poll()
		if socket.get_status()!=StreamPeerTCP.STATUS_CONNECTED or Time.get_ticks_msec()-peer.started>2000: peer.done = true
		var count: int = socket.get_available_bytes()
		if not peer.done and count>0:
			var bytes := socket.get_data(mini(count,1048576))
			if bytes[0]!=OK: peer.done = true; continue
			peer.text += bytes[1].get_string_from_utf8()
			if peer.text.length()>1048576: peer.done = true; continue
			if "\n" in peer.text:
				var parsed = JSON.parse_string(peer.text.get_slice("\n",0))
				var result: Dictionary = universe.handle(parsed) if parsed is Dictionary else {"ok":false,"error":"invalid_json"}
				socket.put_data((JSON.stringify(result)+"\n").to_utf8_buffer())
				peer.done = true
	for peer in peers:
		if peer.done: peer.socket.disconnect_from_host()
	peers = peers.filter(func(peer: Dictionary) -> bool: return not peer.done)
	return false
