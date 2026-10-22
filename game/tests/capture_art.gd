extends SceneTree
## Real engine screenshots. Before/after share camera, anchors, states and viewport.

func _initialize() -> void:
	call_deferred("run")

func save(viewport: SubViewport, path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	if viewport.get_texture().get_image().save_png(path)!=OK:
		push_error("Could not save "+path)
		quit(1)

func run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/g0_5/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/art/art_sample.tscn").instantiate()
		viewport.add_child(scene)
		if not is_instance_valid(scene.garden):
			quit(1)
			return
		scene.set_process(false)
		scene.garden.animation_enabled = false
		scene.garden.clock = 1.5
		await process_frame
		var prefix := output.path_join("art_"+str(resolution.x)+"x"+str(resolution.y))
		scene.set_before(true)
		await save(viewport,prefix+"_before.png")
		scene.set_before(false)
		await save(viewport,prefix+"_after.png")
		scene.toggle_halloween()
		await save(viewport,prefix+"_halloween.png")
		scene.show_kit()
		await save(viewport,prefix+"_ui_kit.png")
		scene.close_panel()
		scene.garden.animation_enabled = true
		var timings: Array[float] = []
		for i in range(70):
			var start := Time.get_ticks_usec()
			await RenderingServer.frame_post_draw
			if i>=10:
				timings.append((Time.get_ticks_usec()-start)/1000.0)
		timings.sort()
		print("ART_FRAME_SAMPLE ",resolution," median_ms=",timings[30]," p95_ms=",timings[57]," includes GPU/display cadence; not physical mobile")
		viewport.queue_free()
		await process_frame
	print("G0.5 real captures PASS")
	quit(0)
