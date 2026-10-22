extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/g0_5r/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var lab = load("res://scenes/art/art_lab.tscn").instantiate()
		viewport.add_child(lab)
		lab.world.motion = false
		for key in ["compact","dense","avenues"]:
			lab.select_fixture(key)
			lab.frame_all()
			await process_frame
			await RenderingServer.frame_post_draw
			var file := output.path_join("lab_%dx%d_%s.png"%[resolution.x,resolution.y,key])
			if viewport.get_texture().get_image().save_png(file)!=OK:
				quit(1)
				return
		viewport.queue_free()
		await process_frame
	print("G0.5-R lab captures PASS; legacy previews, not final art")
	quit(0)
