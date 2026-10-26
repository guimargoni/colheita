extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/cultures/local_culture_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920),Vector2i(1280,720),Vector2i(720,1280)]:
		var time := Base.ControlledTime.new()
		time.value = Time.get_unix_time_from_system()
		var farm := Service.new(Clock.new(time.now,1,"local.cultures.real.v5"),Base.MemoryStore.new(),func() -> float: return 1)
		check(farm.load_farm(farm.fixture()),"Loads existing domain")
		preload("res://scripts/visual/g1v/demo_setup.gd").new().seed(farm)
		check(int(farm.state.economy.xp)>=32,"Demo earns progression through unchanged service")
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g1v/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		await process_frame
		var before: String = JSON.stringify(farm.state)
		scene.switch_presentation()
		check(scene.presentation=="B","B reachable")
		scene.switch_presentation()
		check(scene.presentation=="A" and JSON.stringify(farm.state)==before,"A/B never mutates logical state")
		for i in range(4):
			check(scene.hit_at(scene.container.position+(scene.world.position+scene.world.plot_center(i))*scene.zoom)==i,"Hit map remains aligned")
		scene.world.motion = false
		scene.world.intensity = 0
		var clock: float = scene.world.clock
		for i in range(100): scene.world.feedback(0,"water")
		scene.world._process(0.1)
		check(scene.world.particles.is_empty() and scene.world.clock==clock,"Reduced/zero disables ambient motion")
		scene.world.motion = true
		scene.world.intensity = 1
		for i in range(100): scene.world.feedback(0,"fertilize")
		check(scene.world.particles.size()<=96,"Bounded particle budget")
		var sample: Dictionary = scene.world.particles[0].duplicate(true)
		sample.age = 0.2
		var exact: Vector2 = scene.world.particle_position(sample)
		sample.age = 0
		for step in range(12): sample.age += 1.0/60
		check(scene.world.particle_position(sample).distance_to(exact)<0.001,"Analytic particle path independent of frame partitions")
		scene.world._process(1)
		check(scene.world.particles.is_empty(),"Particles expire with elapsed time")
		var bean: int = scene.demo.plot_ids.find("plot.home.a")
		var point: Vector2 = scene.container.position+(scene.world.position+scene.world.plot_center(bean))*scene.zoom
		var count: int = int(farm.state.inventory.products.get("crop.bean",0))
		if resolution.x>resolution.y:
			var down := InputEventMouseButton.new()
			down.position = point; down.button_index = MOUSE_BUTTON_LEFT; down.pressed = true
			scene._unhandled_input(down)
			var up := InputEventMouseButton.new()
			up.position = point; up.button_index = MOUSE_BUTTON_LEFT; up.pressed = false
			scene._input(up)
		else:
			var down := InputEventScreenTouch.new()
			down.position = point; down.index = 0; down.pressed = true
			scene._unhandled_input(down)
			var up := InputEventScreenTouch.new()
			up.position = point; up.index = 0; up.pressed = false
			scene._input(up)
		check(int(farm.state.inventory.products.get("crop.bean",0))==count+3,"Mouse/touch immediately harvests once")
		var after: String = JSON.stringify(farm.state)
		for i in range(8): scene.act(bean)
		check(JSON.stringify(farm.state)==after,"Recovery interactions cannot duplicate rewards")
		scene.economy_ui.open_shop()
		await process_frame
		check(scene.panel!=null and scene.panel.size.x<=scene.logical.x,"Shop fits")
		var coins: int = int(farm.state.economy.coins)
		var seeds: int = int(farm.state.inventory.seeds.get("crop.carrot",0))
		scene.economy_ui.buy_quantity = 2
		scene.economy_ui.buy("crop.carrot")
		check(int(farm.state.economy.coins)==coins-4 and int(farm.state.inventory.seeds["crop.carrot"])==seeds+2,"Experimental shop preserves quantity and service price")
		scene.immediate_close()
		scene.economy_ui.open_inventory()
		await process_frame
		check(scene.panel!=null,"Inventory available")
		var products: int = int(farm.state.inventory.products.get("crop.bean",0))
		scene.economy_ui.quantities["crop.bean"] = 1
		scene.economy_ui.sell_one("crop.bean")
		check(int(farm.state.inventory.products["crop.bean"])==products-1,"Experimental inventory preserves partial selling")
		var departing: Control = scene.panel
		scene.close_studio()
		check(scene.panel==null,"Closing releases modal immediately")
		await create_timer(0.25).timeout
		check(not is_instance_valid(departing),"Exit tween completes and frees panel without modal lock")
		# A camera drag over productive plots must not issue commands.
		scene.cancel_input()
		var state_before_pan: String = JSON.stringify(farm.state)
		scene.gesture.press(point,0,true)
		scene.gesture.move(point+Vector2(35,20),0)
		scene.gesture.release(point+Vector2(35,20),0)
		check(JSON.stringify(farm.state)==state_before_pan,"Camera drag never mutates farm")
		scene.open_studio()
		await process_frame
		check(scene.panel!=null,"Effects preferences available")
		viewport.queue_free()
		await process_frame
	print("G1.V visual checks: %d; failures: %d"%[checks,failures])
	quit(1 if failures else 0)
