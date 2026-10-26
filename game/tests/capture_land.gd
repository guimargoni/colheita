extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/land/local_land_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
var serial: int = 0

func _initialize() -> void:
	call_deferred("run")

func act(farm: RefCounted, type: String, payload: Dictionary) -> Dictionary:
	serial += 1
	payload.merge({"request_id":"capture.land."+str(serial),"type":type})
	var result: Dictionary = farm.execute(payload)
	if not result.ok:
		push_error("Capture fixture command failed: "+str(result))
	return result

func earn(farm: RefCounted, time: RefCounted, xp: int) -> void:
	while farm.state.economy.xp<xp:
		if farm.state.inventory.seeds.get("crop.carrot",0)<1:
			act(farm,"buy_seeds",{"crop_id":"crop.carrot","quantity":1})
		var plant := act(farm,"plant",{"plot_id":"plot.home.a","crop_id":"crop.carrot"})
		time.value += 128
		act(farm,"harvest",{"plot_id":"plot.home.a","cycle_id":plant.cycle_id})
		act(farm,"sell_products",{"items":{"crop.carrot":2}})

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
		push_error("Cannot save land capture")
		quit(1)

func run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/g14/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var time := Base.ControlledTime.new()
		var farm := Service.new(Clock.new(time.now,1,"capture.land.v4"),Base.MemoryStore.new(),func() -> float: return 1)
		if not farm.load_farm(farm.fixture()):
			push_error(farm.error)
			quit(1)
			return
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g14/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		scene.set_process(false)
		scene.world.set_process(false)
		var prefix := output.path_join("g14_%dx%d_"%[resolution.x,resolution.y])
		await save(viewport,scene,prefix+"farm.png")
		scene.land_ui.open_plot("plot.expand.1")
		await save(viewport,scene,prefix+"requirements.png")
		scene.close_studio()
		earn(farm,time,8)
		scene.land_ui.open_plot("plot.expand.1")
		await save(viewport,scene,prefix+"eligible.png")
		scene.land_ui.open_plot("plot.expand.1",true)
		while Time.get_ticks_msec()<scene.land_ui.ready_at+20:
			await process_frame
		await save(viewport,scene,prefix+"confirmation.png")
		if not scene.land_ui.confirm_purchase().ok:
			push_error("Capture unlock failed")
		await save(viewport,scene,prefix+"unlocked.png")
		scene.world.effects.clear()
		act(farm,"buy_seeds",{"crop_id":"crop.carrot","quantity":4})
		for id in ["plot.home.b","plot.home.c","plot.home.d","plot.expand.1"]:
			act(farm,"plant",{"plot_id":id,"crop_id":"crop.carrot"})
		time.value += 50
		await save(viewport,scene,prefix+"planted.png")
		time.value += 128
		for id in ["plot.home.b","plot.home.c","plot.home.d","plot.expand.1"]:
			act(farm,"harvest",{"plot_id":id,"cycle_id":farm.state.plots[id].cycle_id})
		act(farm,"sell_products",{"items":{"crop.carrot":8}})
		earn(farm,time,180)
		for id in ["plot.expand.2","plot.expand.3","plot.expand.4"]:
			act(farm,"unlock_plot",{"plot_id":id,"confirmed":true,"expected_revision":farm.state.revision,"quote_version":farm.land_config.version})
		act(farm,"buy_seeds",{"crop_id":"crop.strawberry","quantity":4})
		act(farm,"buy_seeds",{"crop_id":"crop.carrot","quantity":4})
		var ids: Array = farm.state.plots.keys()
		ids.sort()
		for i in range(ids.size()):
			act(farm,"plant",{"plot_id":ids[i],"crop_id":"crop.strawberry" if i%2==0 else "crop.carrot"})
		time.value += 65
		scene.economy_ui.last_level = int(farm.state.economy.level)
		scene.economy_ui.note = "Amostra expandida · contagem e preços provisórios"
		await create_timer(1.3).timeout
		await save(viewport,scene,prefix+"full_farm.png")
		scene.economy_ui.open_history()
		await save(viewport,scene,prefix+"history.png")
		viewport.queue_free()
		await process_frame
	print("G1.4: 16 real GPU captures PASS; fixtures only, no player saves")
	quit(0)
