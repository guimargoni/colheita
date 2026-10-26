extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/cultures/local_culture_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var output: String
var report: Array = []
func _initialize() -> void: call_deferred("run")
func fixture() -> RefCounted:
	var time := Base.ControlledTime.new()
	time.value = 1800000000
	var farm := Service.new(Clock.new(time.now,1,"local.cultures.real.v5"),Base.MemoryStore.new(),func() -> float: return 1)
	farm.load_farm(farm.fixture())
	preload("res://scripts/visual/g1v/demo_setup.gd").new().seed(farm)
	return farm
func shot(viewport: SubViewport, name: String) -> void:
	for i in range(4):
		await process_frame
		await RenderingServer.frame_post_draw
	if viewport.get_texture().get_image().save_png(output.path_join(name+".png"))!=OK:
		push_error("Capture failed"); quit(1)
func run() -> void:
	output = ProjectSettings.globalize_path("res://../.local/g1v/captures")
	DirAccess.make_dir_recursive_absolute(output)
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
			var prefix := "g1v_%dx%d_%s_"%[resolution.x,resolution.y,option]
			await shot(viewport,prefix+"farm")
			scene.economy_ui.open_shop()
			await create_timer(0.25).timeout
			await shot(viewport,prefix+"shop")
			scene.immediate_close()
			scene.economy_ui.open_inventory()
			await create_timer(0.25).timeout
			await shot(viewport,prefix+"inventory")
			scene.immediate_close()
			# Actual engine frames, action schedule, no image interpolation.
			if resolution.x==1920:
				viewport.size = Vector2i(960,540)
				scene.resize()
				var bean: int = scene.demo.plot_ids.find("plot.home.a")
				var rose: int = scene.demo.plot_ids.find("plot.home.b")
				for i in range(72):
					if i==12: scene.act(bean)
					if i==28: scene.demo.tool = "water"; scene.act(rose)
					if i==43: scene.demo.tool = "fertilize"; scene.act(rose)
					if i==52: scene.economy_ui.open_shop()
					if i==64: scene.close_studio()
					await create_timer(1.0/24.0).timeout
					await RenderingServer.frame_post_draw
					viewport.get_texture().get_image().save_png(output.path_join("motion_%s_%03d.png"%[option,i]))
			viewport.queue_free()
			await process_frame
	print("G1.V: 12 real GPU stills + 144 real motion frames PASS")
	quit()
