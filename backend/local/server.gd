extends SceneTree
const Universe = preload("res://scripts/services/integrated/universe.gd")
var listener := TCPServer.new()
var peers: Array[Dictionary] = []
var universe: RefCounted
var port: int = 16661
var last_activity: int = Time.get_ticks_msec()
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
	if peers.is_empty() and Time.get_ticks_msec()-last_activity>120000:
		print("Local server idle; all mutations already persisted"); quit(); return false
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
				last_activity = Time.get_ticks_msec()
				if peer.text.begins_with("GET "):
					socket.put_data(invite_page(peer.text.get_slice("\n",0)).to_utf8_buffer())
				else:
					var parsed = JSON.parse_string(peer.text.get_slice("\n",0))
					var result: Dictionary = universe.handle(parsed) if parsed is Dictionary else {"ok":false,"error":"invalid_json"}
					if result.get("ok",false) and result.has("code"): result.link = "http://127.0.0.1:%d/invite/%s"%[port,result.code]
					socket.put_data((JSON.stringify(result)+"\n").to_utf8_buffer())
				peer.done = true
	for peer in peers:
		if peer.done: peer.socket.disconnect_from_host()
	peers = peers.filter(func(peer: Dictionary) -> bool: return not peer.done)
	return false

func invite_page(request_line: String) -> String:
	var path: String = request_line.get_slice(" ",1)
	var code: String = path.trim_prefix("/invite/") if path.begins_with("/invite/") else ""
	var invite: Dictionary = universe.data.invites.get(code,{})
	var valid: bool = code.length()==32 and code.is_valid_hex_number(false) and not invite.is_empty() and not invite.get("revoked",true) and invite.get("expires",0)>Time.get_unix_time_from_system()
	var body: String
	if valid:
		var name: String = str(universe.data.accounts.get(invite.owner,{}).get("name","Fazendeiro")).xml_escape()
		body = '<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Convite Colheita</title><style>body{font:20px system-ui;background:#fff4df;color:#244f47;max-width:650px;margin:10vh auto;padding:24px}input{font:18px monospace;width:100%;padding:12px}</style><h1>Um convite para sua fazenda</h1><p>'+name+' quer encontrar você no Colheita.</p><p>Ambiente local deste computador. Abra JOGAR_COLHEITAFELIZ.cmd e, em Amigos, cole o código abaixo. A amizade só começa depois da aceitação.</p><input readonly aria-label="Código do convite" value="'+code+'"><p>Para pessoas em outro aparelho, ainda será necessária uma hospedagem pública e uma versão distribuível do aplicativo.</p></html>'
	else: body = '<!doctype html><meta charset="utf-8"><title>Convite indisponível</title><h1>Convite expirado, revogado ou inexistente</h1>'
	var status: String = "200 OK" if valid else "404 Not Found"
	return "HTTP/1.1 "+status+"\r\nContent-Type: text/html; charset=utf-8\r\nCache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\nContent-Length: "+str(body.to_utf8_buffer().size())+"\r\nConnection: close\r\n\r\n"+body
