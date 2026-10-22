extends SceneTree
## Real G0.4 viewport captures and a short desktop render timing sample.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/g0_4/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene: Control = load("res://scenes/experience/experience.tscn").instantiate()
		viewport.add_child(scene)
		scene.set_process(false)
		scene.garden.animation_enabled = false
		scene.garden.clock = 2
		scene.garden.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var prefix := output.path_join("experience_"+str(resolution.x)+"x"+str(resolution.y))
		if viewport.get_texture().get_image().save_png(prefix+".png")!=OK:
			quit(1)
			return
		scene._act(0)
		scene.demo.selected_seed = 1
		scene._act(2)
		scene.demo.tool = "water"
		scene._act(5)
		await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png(prefix+"_actions.png")
		scene.open_panel("Configurações")
		await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png(prefix+"_settings.png")
		print("Captured G0.4: ",resolution)
		scene.close_panel()
		scene.garden.animation_enabled = true
		var timings: Array[float] = []
		for i in range(90):
			var start := Time.get_ticks_usec()
			await RenderingServer.frame_post_draw
			var elapsed := float(Time.get_ticks_usec()-start)/1000
			if i>=10:
				timings.append(elapsed)
		timings.sort()
		print("FRAME_SAMPLE ",resolution," median_ms=",timings[timings.size()/2]," p95_ms=",timings[int(timings.size()*0.95)]," (GPU/display cadence included; not mobile hardware)")
		viewport.queue_free()
		await process_frame
	print("G0.4 captures PASS")
	quit(0)
