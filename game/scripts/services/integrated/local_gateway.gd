extends RefCounted
## Loopback DEV transport; no credentials compiled into the client.
var token: String
var port: int
func _init(credential: String, server_port: int) -> void: token = credential; port = server_port
func request(method: String, args: Dictionary = {}, operation: String = "") -> Dictionary:
	var peer := StreamPeerTCP.new()
	if peer.connect_to_host("127.0.0.1",port)!=OK: return {"ok":false,"error":"server_unavailable"}
	var deadline: int = Time.get_ticks_msec()+1800
	while Time.get_ticks_msec()<deadline:
		peer.poll()
		if peer.get_status()==StreamPeerTCP.STATUS_CONNECTED: break
		if peer.get_status()==StreamPeerTCP.STATUS_ERROR: return {"ok":false,"error":"server_unavailable"}
		OS.delay_msec(1)
	if peer.get_status()!=StreamPeerTCP.STATUS_CONNECTED: return {"ok":false,"error":"server_timeout"}
	var payload := {"method":method,"token":token,"args":args,"request_id":operation if not operation.is_empty() else Crypto.new().generate_random_bytes(16).hex_encode()}
	if peer.put_data((JSON.stringify(payload)+"\n").to_utf8_buffer())!=OK: return {"ok":false,"error":"server_send_failed"}
	var text: String = ""
	while Time.get_ticks_msec()<deadline:
		peer.poll()
		var size: int = peer.get_available_bytes()
		if size>0:
			var packet := peer.get_data(size)
			if packet[0]!=OK: break
			text += packet[1].get_string_from_utf8()
			if text.length()>2097152: return {"ok":false,"error":"response_limit"}
			if "\n" in text:
				var value = JSON.parse_string(text.get_slice("\n",0))
				return value if value is Dictionary else {"ok":false,"error":"invalid_server_reply"}
		if peer.get_status()==StreamPeerTCP.STATUS_ERROR: break
		OS.delay_msec(1)
	return {"ok":false,"error":"server_timeout"}
