extends SceneTree
## Render the real scenes through GPU-backed SubViewports at exact target sizes.

var output_path: String


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	output_path = ProjectSettings.globalize_path("res://../.local/g0_3/captures")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):
			output_path = arg.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(output_path)
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		for proposal: String in ["menu","a","b"]:
			var viewport := SubViewport.new()
			viewport.size = resolution
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			viewport.transparent_bg = false
			root.add_child(viewport)
			var scene_path := "res://scenes/comparison/comparison_menu.tscn" if proposal == "menu" else "res://scenes/comparison/proposal_"+proposal+".tscn"
			var scene: Control = load(scene_path).instantiate()
			viewport.add_child(scene)
			scene.world.animation_enabled = false
			scene.world.clock = 2.0
			scene.world.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			var filename := output_path.path_join("proposal_"+proposal+"_"+str(resolution.x)+"x"+str(resolution.y)+".png")
			var image := viewport.get_texture().get_image()
			if image == null or image.save_png(filename) != OK:
				push_error("Capture failed: " + filename)
				quit(1)
				return
			print("Captured ",filename)
			if proposal != "menu":
				scene.focus_plots()
				await process_frame
				await RenderingServer.frame_post_draw
				var detail_name := output_path.path_join("proposal_"+proposal+"_"+str(resolution.x)+"x"+str(resolution.y)+"_detail.png")
				if viewport.get_texture().get_image().save_png(detail_name) != OK:
					push_error("Detail capture failed")
					quit(1)
					return
				print("Captured ",detail_name)
			viewport.queue_free()
			await process_frame
	print("Captures PASS: menu, overview and plot detail at both target resolutions")
	quit(0)
