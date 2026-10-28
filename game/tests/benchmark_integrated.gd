extends SceneTree
var results: Array = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm := preload("res://tests/integrated_sample.gd").new().create()
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var scene = load("res://scenes/main/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		for i in range(30): await process_frame
		var frames: Array[float] = []
		var previous := Time.get_ticks_usec()
		var start := previous
		for i in range(240):
			if i%12==0: scene.world.feedback(0,"water")
			await process_frame
			var current := Time.get_ticks_usec()
			frames.append((current-previous)/1000.0)
			previous = current
		var elapsed := (Time.get_ticks_usec()-start)/1000000.0
		frames.sort()
		results.append({"resolution":"%dx%d"%[resolution.x,resolution.y],"frames":240,"fps":240.0/elapsed,"p50_ms":frames[119],"p95_ms":frames[227],"max_ms":frames.back(),"adapter":RenderingServer.get_video_adapter_name(),"scope":"PC wall frame time; local fixture, no network or physical phone"})
		viewport.queue_free()
		await process_frame
	await create_timer(0.2).timeout
	var file := FileAccess.open("res://../.local/integrated/performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"  "))
	print("Integrated performance: "+JSON.stringify(results))
	quit()
