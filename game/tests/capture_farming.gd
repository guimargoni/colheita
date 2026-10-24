extends SceneTree

const Tests = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/farming/local_farm_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")

func _initialize() -> void:
	call_deferred("run")

func save(viewport: SubViewport, path: String) -> void:
	for i in range(3):
		await process_frame
		await RenderingServer.frame_post_draw
	if viewport.get_texture().get_image().save_png(path)!=OK:
		push_error("Could not save farming capture")
		quit(1)

func run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/g11/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var time = Tests.ControlledTime.new()
		var farm := Service.new(Clock.new(time.now),Tests.MemoryStore.new())
		var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))
		if not farm.load_farm(fixture):
			quit(1)
			return
		var ids: Array = farm.state.plots.keys()
		ids.sort()
		for i in range(3):
			var crop: Dictionary = farm.catalog.entries[farm.catalog.ids[i]]
			time.value = 10000-float(crop.growth_seconds)*[1.1,0.5,0.1][i]
			farm.execute({"request_id":"capture.plant."+str(i),"type":"plant","plot_id":ids[i],"crop_id":crop.id})
		time.value = 10000
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g11/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		scene.set_process(false)
		scene.world.set_process(false)
		var prefix := output.path_join("g11_%dx%d_"%[resolution.x,resolution.y])
		await save(viewport,prefix+"farm.png")
		for i in range(3):
			scene.inspect(i)
			await save(viewport,prefix+"crop_"+str(i+1)+".png")
		scene.open_inventory()
		await save(viewport,prefix+"inventory_before.png")
		scene.close_studio()
		scene.act(0)
		await save(viewport,prefix+"harvest.png")
		scene.world.effects.clear()
		scene.world.queue_redraw()
		scene.open_inventory()
		await save(viewport,prefix+"inventory_after.png")
		scene.close_studio()
		scene.act(0)
		scene.world.effects.clear()
		scene.world.queue_redraw()
		await save(viewport,prefix+"planted.png")
		time.value += 43
		scene.demo.refresh()
		scene.inspect(0)
		scene.world.queue_redraw()
		await save(viewport,prefix+"growing.png")
		viewport.queue_free()
		await process_frame
	print("G1.1: 18 real GPU captures PASS (controlled clock, isolated test fixture; no user save touched)")
	quit(0)
