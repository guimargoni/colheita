extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/cultures/local_culture_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
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
	var output := ProjectSettings.globalize_path("res://../.local/g15/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var time := Base.ControlledTime.new()
		var farm := Service.new(Clock.new(time.now,1,"capture.cultures.v5"),Base.MemoryStore.new(),func() -> float: return 1)
		if not farm.load_farm(farm.fixture()):
			push_error(farm.error); quit(1); return
		earn(farm,time,32)
		time.value = float(farm.events.values()[0].start)+1000
		var planted_at: float = time.value
		var crops: Array = ["crop.bean","crop.rose","crop.haunted_pumpkin","crop.carrot"]
		var plots: Array = ["plot.home.a","plot.home.b","plot.home.c","plot.home.d"]
		for i in range(4):
			act(farm,"buy_seeds",{"crop_id":crops[i],"quantity":1})
			act(farm,"plant",{"plot_id":plots[i],"crop_id":crops[i]})
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g15/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		scene.set_process(false)
		scene.world.set_process(false)
		scene.economy_ui.note = "Feijão · rosa · abóbora original · cenoura"
		var prefix := output.path_join("g15_%dx%d_"%[resolution.x,resolution.y])
		await save(viewport,scene,prefix+"seed.png")
		time.value = planted_at+650
		await save(viewport,scene,prefix+"growing.png")
		time.value = planted_at+4000
		scene.world.clock = 0
		await save(viewport,scene,prefix+"mature_unlit.png")
		scene.world.clock = 2.8
		await save(viewport,scene,prefix+"mature_lit.png")
		var bean: int = scene.demo.plot_ids.find("plot.home.a")
		scene.inspect(bean)
		await save(viewport,scene,prefix+"context.png")
		scene.act(bean)
		await save(viewport,scene,prefix+"regrowth.png")
		scene.world.effects.clear()
		for i in range(2):
			time.value += 330
			scene.demo.refresh()
			scene.act(bean)
			scene.world.effects.clear()
		await save(viewport,scene,prefix+"final_empty.png")
		act(farm,"harvest",{"plot_id":"plot.home.b","cycle_id":farm.state.plots["plot.home.b"].cycle_id})
		scene.economy_ui.filter_category = "flower"
		scene.economy_ui.open_inventory()
		await save(viewport,scene,prefix+"flower_inventory.png")
		scene.economy_ui.filter_category = "special"
		scene.economy_ui.open_shop()
		await save(viewport,scene,prefix+"special_shop.png")
		time.value = float(farm.events.values()[0].end)
		scene.economy_ui.open_shop()
		await save(viewport,scene,prefix+"event_closed.png")
		viewport.queue_free()
		await process_frame
	print("G1.5: 20 real GPU captures PASS; isolated fixtures, original sprites")
	quit(0)
