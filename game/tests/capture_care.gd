extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/care/local_care_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")

func _initialize() -> void:
	call_deferred("run")

func save(viewport: SubViewport, scene: Control, path: String) -> void:
	scene.update_context()
	scene.world.queue_redraw()
	for i in range(3):
		await process_frame
		await RenderingServer.frame_post_draw
	if viewport.get_texture().get_image().save_png(path)!=OK:
		push_error("Cannot save care capture")
		quit(1)

func run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/g12/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var time = Base.ControlledTime.new()
		var farm := Service.new(Clock.new(time.now),Base.MemoryStore.new(),func() -> float: return 0)
		var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
		farm.load_farm(fixture)
		var ids: Array = farm.state.plots.keys()
		ids.sort()
		var crops := ["crop.wheat","crop.strawberry","crop.carrot","crop.carrot"]
		for i in range(4):
			time.value = 10000-float(farm.catalog.entries[crops[i]].growth_seconds)*(1.2 if i==3 else 0.4)
			farm.execute({"request_id":"capture.plant."+str(i),"type":"plant","plot_id":ids[i],"crop_id":crops[i]})
		time.value = 10000
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g12/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		scene.set_process(false)
		scene.world.set_process(false)
		var prefix := output.path_join("g12_%dx%d_"%[resolution.x,resolution.y])
		await save(viewport,scene,prefix+"farm.png")
		scene.inspect(0)
		await save(viewport,scene,prefix+"context.png")
		scene.open_care_tools()
		await save(viewport,scene,prefix+"tools.png")
		scene.select_care("water")
		scene.act(0)
		await save(viewport,scene,prefix+"water.png")
		scene.select_care("remove_pests")
		scene.world.effects.clear()
		scene.act(0)
		await save(viewport,scene,prefix+"pests_removed.png")
		scene.select_care("remove_weeds")
		scene.world.effects.clear()
		scene.act(0)
		await save(viewport,scene,prefix+"weeds_removed.png")
		scene.select_care("fertilizer.common")
		scene.world.effects.clear()
		scene.act(0)
		await save(viewport,scene,prefix+"fertilized.png")
		scene.open_care_tools()
		await save(viewport,scene,prefix+"stock_after.png")
		scene.close_studio()
		scene.world.effects.clear()
		scene.act(3)
		await save(viewport,scene,prefix+"harvest.png")
		viewport.queue_free()
		await process_frame
	print("G1.2: 18 real GPU captures PASS; controlled care fixture, no player save touched")
	quit(0)
