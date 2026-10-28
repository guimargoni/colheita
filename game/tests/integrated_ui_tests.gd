extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/integrated/farm_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920),Vector2i(1280,720),Vector2i(720,1280)]:
		var time := Base.ControlledTime.new()
		var farm := Service.new(Clock.new(time.now,1,"integrated.ui.v1"),Base.MemoryStore.new(),func() -> float: return 1)
		check(farm.load_farm(farm.fixture()),"Farm loads")
		var viewport := SubViewport.new(); viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/main/farm.tscn").instantiate()
		scene.injected_service = farm; viewport.add_child(scene)
		await process_frame
		check(not scene.startup_error,"Main scene initialized")
		for id in range(scene.demo.plots.size()):
			var at: Vector2 = scene.container.position+scene.world.position+scene.world.plot_center(id)*scene.zoom
			check(scene.hit_at(at)==id,"Smooth renderer hit map aligned")
		scene.economy_ui.open_shop(); await process_frame
		check(scene.panel.size.x<=scene.logical.x,"Shop fits")
		scene.economy_ui.open_inventory(); await process_frame
		check(scene.panel!=null,"Inventory opens with all categories")
		scene.open_farm_hub(); await process_frame
		check(scene.panel!=null,"Animal panel opens")
		scene.features_panel.open("Decoração"); await process_frame
		scene.features_panel.place_options("flowerpot",""); await process_frame
		var before: int = int(farm.state.economy.coins)
		scene.feature_action("buy_decoration",{"kind":"flowerpot","slot":0})
		check(farm.state.features.decorations.size()==1 and farm.state.economy.coins==before-8,"UI places a real paid object")
		scene.features_panel.open("Construções"); await process_frame
		scene.features_panel.open("Conquistas"); await process_frame
		scene.features_panel.open("Social"); await process_frame
		check(scene.panel!=null,"Offline social states server requirement explicitly")
		scene.open_studio(); await process_frame
		check(scene.audio.players.size()==8,"Bounded licensed audio pool")
		scene.close_studio(); await create_timer(0.25).timeout
		check(scene.panel==null,"Settings closes")
		viewport.queue_free(); await process_frame
	await create_timer(0.2).timeout
	print("Integrated UI checks: %d; failures: %d"%[checks,failures])
	quit(1 if failures else 0)
