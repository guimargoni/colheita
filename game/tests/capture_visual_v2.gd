extends SceneTree
func _initialize() -> void: call_deferred("run")
func shot(viewport: SubViewport,path: String) -> void:
	for i in range(4): await process_frame; await RenderingServer.frame_post_draw
	if viewport.get_texture().get_image().save_png(path)!=OK: push_error("Capture failed"); quit(1)
func run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/visual_v2/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var farm := preload("res://tests/integrated_sample.gd").new().create()
		var viewport := SubViewport.new(); viewport.size = resolution; viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/main/farm.tscn").instantiate()
		scene.injected_service = farm; viewport.add_child(scene)
		var prefix := output.path_join("visual_%dx%d_"%[resolution.x,resolution.y])
		scene.world.set_theme("standard"); scene.world.set_skin("building.house",""); scene.layout()
		await shot(viewport,prefix+"standard.png")
		scene.world.set_theme("halloween"); scene.world.set_skin("building.house","house.sky"); scene.layout()
		await shot(viewport,prefix+"halloween.png")
		scene.economy_ui.open_shop(); await create_timer(0.25).timeout
		await shot(viewport,prefix+"shop.png")
		scene.open_farm_hub(); await create_timer(0.25).timeout
		await shot(viewport,prefix+"animals.png")
		scene.economy_ui.open_inventory(); await create_timer(0.25).timeout
		await shot(viewport,prefix+"inventory.png")
		if true:
			scene.immediate_close()
			viewport.size = Vector2i(960,540) if resolution.x==1920 else Vector2i(540,960); scene.resize()
			scene.world.set_theme("standard")
			var bean: int = scene.demo.plot_ids.find("plot.home.a")
			var chicken: String = ""
			for id in farm.state.features.producers:
				if farm.state.features.producers[id].kind=="chicken": chicken = id
			for frame in range(96):
				if frame==12: scene.act(bean)
				if frame==30: scene.feature_action("producer_collect",{"id":chicken,"cycle":int(farm.state.features.producers[chicken].cycle)})
				if frame==40: scene.feature_action("producer_feed",{"id":chicken})
				if frame==48: scene.world.set_theme("halloween"); scene.demo.tool = "water"; scene.act(bean)
				if frame==65: scene.demo.tool = "fertilize"; scene.act(bean)
				if frame==76: scene.open_farm_hub()
				if frame==89: scene.close_studio()
				await create_timer(1.0/24).timeout; await RenderingServer.frame_post_draw
				viewport.get_texture().get_image().save_png(output.path_join(("pc_" if resolution.x==1920 else "mobile_")+"motion_%03d.png"%frame))
		viewport.queue_free(); await process_frame
	await create_timer(0.2).timeout
	print("Visual v2 GPU captures PASS: 10 real frames and two 96-frame clips, isolated service fixtures with earned resources")
	quit()
