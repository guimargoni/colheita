extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/cultures/local_culture_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var results: Array = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		for option in ["A","B"]:
			var viewport := SubViewport.new()
			viewport.size = resolution
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(viewport)
			var scene = load("res://scenes/farm/g1v/farm.tscn").instantiate()
			scene.injected_service = fixture()
			viewport.add_child(scene)
			if option=="B": scene.switch_presentation()
			scene.world.intensity = 1
			for i in range(30): await process_frame
			var frames: Array[float] = []
			var previous: int = Time.get_ticks_usec()
			var start: int = previous
			for i in range(240):
				if i%12==0: scene.world.feedback(scene.demo.plot_ids.find("plot.home.b"),"water")
				await process_frame
				var current: int = Time.get_ticks_usec()
				frames.append((current-previous)/1000.0)
				previous = current
			var elapsed: float = (Time.get_ticks_usec()-start)/1000000.0
			frames.sort()
			results.append({"resolution":"%dx%d"%[resolution.x,resolution.y],"option":option,"frames":240,"fps":240.0/elapsed,"p50_ms":frames[119],"p95_ms":frames[227],"max_ms":frames.back(),"intensity":1,"particle_cap":96,"renderer":RenderingServer.get_current_rendering_method(),"adapter":RenderingServer.get_video_adapter_name(),"scope":"PC viewport, process-frame wall time; not mobile hardware nor isolated GPU time"})
			viewport.queue_free()
			await process_frame
	var file := FileAccess.open("res://../.local/g1v/performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"  "))
	print("G1.V performance: 4 runs x 240 measured frames; "+JSON.stringify(results))
	quit()

func fixture() -> RefCounted:
	var time := Base.ControlledTime.new()
	time.value = 1800000000
	var farm := Service.new(Clock.new(time.now,1,"local.cultures.real.v5"),Base.MemoryStore.new(),func() -> float: return 1)
	farm.load_farm(farm.fixture())
	preload("res://scripts/visual/g1v/demo_setup.gd").new().seed(farm)
	return farm
