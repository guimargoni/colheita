extends SceneTree
const Remote = preload("res://scripts/services/integrated/remote_farm.gd")
var role: String
var mailbox: String
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func require(ok: bool,message: String) -> bool:
	checks += 1
	if not ok: failures += 1; push_error(message); quit(1)
	return ok
func run() -> void:
	var port: int = 16664
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--role="): role = arg.trim_prefix("--role=")
		if arg.begins_with("--mailbox="): mailbox = arg.trim_prefix("--mailbox=")
		if arg.begins_with("--port="): port = arg.trim_prefix("--port=").to_int()
	var client := Remote.new("one" if role=="sender" else "two",port)
	if not require(client.error.is_empty(),"Independent client authentication"): return
	var deadline: int = Time.get_ticks_msec()+20000
	if role=="sender":
		var invite: Dictionary = client.social("invite_create")
		if not require(invite.ok,"Create invite on real server"): return
		var file := FileAccess.open(mailbox+"/invite.json",FileAccess.WRITE); file.store_string(JSON.stringify({"code":invite.code})); file.close()
		var friend: String = ""
		while Time.get_ticks_msec()<deadline and friend.is_empty():
			var social: Dictionary = client.social("social_state")
			for request in social.get("requests",[]):
				if request.to.id==client.player.id:
					friend = request.from.id
					if not require(client.social("friend_accept",{"target":friend}).ok,"Accept invitation from separate process"): return
			await create_timer(0.08).timeout
		if not require(not friend.is_empty(),"Receiver process reached invitation"): return
		var planted: Dictionary = client.execute({"type":"plant","plot_id":"plot.home.a","crop_id":"crop.carrot","request_id":"multiprocess.plant"})
		if not require(planted.ok,"Sender really plants"): return
		file = FileAccess.open(mailbox+"/ready.json",FileAccess.WRITE); file.store_string("{}"); file.close()
		var helped: bool = false
		while Time.get_ticks_msec()<deadline and not helped:
			var social: Dictionary = client.social("social_state")
			for row in social.get("activity",[]):
				if row.action=="help" and row.actor==friend: helped = true
			await create_timer(0.08).timeout
		require(helped,"Owner sees other process help in server history")
	else:
		while not FileAccess.file_exists(mailbox+"/invite.json") and Time.get_ticks_msec()<deadline: await create_timer(0.08).timeout
		if not require(FileAccess.file_exists(mailbox+"/invite.json"),"Invite link exchanged as in manual test"): return
		var invitation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(mailbox+"/invite.json"))
		if not require(client.social("invite_redeem",{"code":invitation.code}).ok,"Receiver redeems invite on server"): return
		while not FileAccess.file_exists(mailbox+"/ready.json") and Time.get_ticks_msec()<deadline: await create_timer(0.08).timeout
		var social: Dictionary = client.social("social_state")
		if not require(not social.get("friends",[]).is_empty(),"Server friendship available in second process"): return
		var friend: String = social.friends[0].id
		var visit: Dictionary = client.social("visit",{"target":friend})
		if not require(visit.ok and visit.plots["plot.home.a"].crop_id=="crop.carrot","Second process visits actual crop"): return
		if not require(client.social("help",{"target":friend,"plot_id":"plot.home.a","action":"water"}).ok,"Second process waters actual crop"): return
		require(client.execute({"type":"plant","plot_id":"plot.home.a","crop_id":"crop.carrot","request_id":"multiprocess.receiver.plant"}).ok,"Second process retains independent owner farming")
	client.shutdown()
	print("Separate Godot process "+role+(": PASS " if failures==0 else ": FAIL ")+str(checks)+" checks")
	quit(1 if failures else 0)
