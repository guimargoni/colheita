extends SceneTree
const Remote = preload("res://scripts/services/integrated/remote_farm.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,text: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(text)
func run() -> void:
	var port: int = 16664
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--port="): port = arg.trim_prefix("--port=").to_int()
	var one := Remote.new("one",port)
	var two := Remote.new("two",port)
	check(one.error.is_empty() and two.error.is_empty(),"Two native clients authenticate")
	if not one.error.is_empty() or not two.error.is_empty(): quit(1); return
	check(one.player.id!=two.player.id,"Separate native player identities")
	var social: Dictionary = one.social("social_state")
	var friends: Array = social.get("friends",[]).map(func(p: Dictionary) -> String: return p.id)
	if two.player.id not in friends:
		check(one.social("friend_request",{"target":two.player.id}).ok,"Native friend request")
		check(two.social("friend_accept",{"target":one.player.id}).ok,"Native friend acceptance")
	var viewport := SubViewport.new(); viewport.size = Vector2i(1080,1920)
	root.add_child(viewport)
	var scene = load("res://scenes/main/farm.tscn").instantiate()
	scene.injected_service = one; viewport.add_child(scene)
	await process_frame
	scene.open_social(); await process_frame
	check(scene.panel!=null,"Native social panel opens")
	scene.social_panel.visit(two.player.id); await process_frame
	check(scene.panel!=null and scene.panel.find_children("*","SubViewport",true,false).size()==1,"Real friend farm renders in visit UI")
	scene.close_studio(); await create_timer(0.25).timeout
	viewport.queue_free(); await process_frame
	one.shutdown(); two.shutdown()
	await create_timer(0.1).timeout
	print("Native server/client UI checks: %d; failures: %d"%[checks,failures])
	quit(1 if failures else 0)
