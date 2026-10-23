extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func save(viewport: SubViewport, path: String) -> void:
	for i in range(3):
		await process_frame
		await RenderingServer.frame_post_draw
	if viewport.get_texture().get_image().save_png(path)!=OK:
		push_error("Could not save capture")
		quit(1)

func run() -> void:
	var output := ProjectSettings.globalize_path("res://../.local/pilot_v2/captures")
	DirAccess.make_dir_recursive_absolute(output)
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/art/pilot/pilot.tscn").instantiate()
		viewport.add_child(scene)
		scene.set_process(false)
		scene.world.set_process(false)
		var prefix := output.path_join("pilot_%dx%d_"%[resolution.x,resolution.y])
		await save(viewport,prefix+"farm.png")
		scene.act(0)
		for i in range(3):
			scene.world.effects[0].age = [0.04,0.18,0.36][i]
			scene.world.queue_redraw()
			await save(viewport,prefix+"harvest_0"+str(i+1)+".png")
		scene.world.effects.clear()
		scene.world.queue_redraw()
		scene.open_studio()
		await save(viewport,prefix+"studio.png")
		viewport.queue_free()
		await process_frame
	print("Independent Cozy pilot: ten real captures PASS")
	quit(0)
