extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/economy/local_economy_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
var serial: int = 0

func _initialize() -> void:
	call_deferred("run")

func act(farm: RefCounted, type: String, payload: Dictionary) -> Dictionary:
	serial += 1
	payload.merge({"request_id":"capture."+str(serial),"type":type})
	return farm.execute(payload)

func save(viewport: SubViewport, scene: Control, path: String) -> void:
	scene.demo.refresh()
	scene.seed_label.text = scene.demo.tool_summary()
	scene.economy_ui.tick(10)
	scene.update_context()
	scene.world.queue_redraw()
	for i in range(4):
		await process_frame
		await RenderingServer.frame_post_draw
	if viewport.get_texture().get_image().save_png(path)!=OK:
		push_error("Cannot save economy capture")
		quit(1)

func run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/g13/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var time := Base.ControlledTime.new()
		var farm := Service.new(Clock.new(time.now,1,"capture.economy.v3"),Base.MemoryStore.new(),func() -> float: return 0)
		var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
		farm.load_farm(fixture)
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g13/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		scene.set_process(false)
		scene.world.set_process(false)
		var prefix := output.path_join("g13_%dx%d_"%[resolution.x,resolution.y])
		scene.economy_ui.open_shop()
		await save(viewport,scene,prefix+"shop_locked.png")
		scene.economy_ui.buy_quantity = 5
		scene.economy_ui.buy("crop.carrot")
		await save(viewport,scene,prefix+"purchase.png")
		scene.close_studio()
		var ids: Array = farm.state.plots.keys()
		ids.sort()
		for i in range(2):
			for id in ids:
				act(farm,"plant",{"plot_id":id,"crop_id":"crop.carrot"})
			time.value += 128
			for id in ids:
				act(farm,"harvest",{"plot_id":id,"cycle_id":farm.state.plots[id].cycle_id})
		act(farm,"buy_seeds",{"crop_id":"crop.strawberry","quantity":2})
		act(farm,"plant",{"plot_id":ids[0],"crop_id":"crop.strawberry"})
		act(farm,"plant",{"plot_id":ids[1],"crop_id":"crop.carrot"})
		time.value += 70
		scene.economy_ui.tick(10)
		await save(viewport,scene,prefix+"level_up.png")
		scene.economy_ui.open_inventory()
		await save(viewport,scene,prefix+"inventory.png")
		scene.economy_ui.selected["crop.carrot"] = true
		scene.economy_ui.sell_selected()
		await save(viewport,scene,prefix+"sale.png")
		scene.economy_ui.open_shop()
		await save(viewport,scene,prefix+"shop_unlocked.png")
		scene.economy_ui.open_history()
		await save(viewport,scene,prefix+"history.png")
		scene.close_studio()
		scene.economy_ui.note = "G1.3 · economia local de desenvolvimento"
		await create_timer(1.3).timeout
		await save(viewport,scene,prefix+"farm.png")
		viewport.queue_free()
		await process_frame
	print("G1.3: 16 real GPU captures PASS; controlled fixture, no player saves")
	quit(0)
