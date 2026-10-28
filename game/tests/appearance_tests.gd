extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/integrated/farm_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../.local/visual_v2"))
	var resolver := preload("res://scripts/visual/appearance/resolver.gd").new()
	check(resolver.pack.contracts.size()==11,"Family contracts present")
	var house := resolver.resolve("building.house","environment.house")
	check(resolver.set_skin("building.house","house.sky"),"Individual house skin accepted")
	var blue := resolver.resolve("building.house","environment.house")
	check(house.pivot==blue.pivot and house.size==blue.size and house.rect!=blue.rect,"Skin changes art without changing contact/envelope")
	check(not resolver.set_skin("animal.cow","house.sky"),"Cross-family skin rejected")
	check(not resolver.set_theme("missing"),"Unknown theme rejected")
	for key in resolver.pack.assets:
		var entry: Dictionary = resolver.pack.assets[key]
		var texture: Texture2D = resolver.texture(entry)
		var rect: Array = entry.rect
		check(rect[0]>=0 and rect[1]>=0 and rect[0]+rect[2]<=texture.get_width() and rect[1]+rect[3]<=texture.get_height(),"Atlas region within source: "+key)
	check(resolver.resolve("crop.carrot","culture.crop.carrot","mature").key=="crops.carrot_mature","Functional state selects appearance")
	resolver.pack.assets.broken = {"texture":"res://missing.png","fallback":"crops.soil"}
	resolver.pack.themes.halloween.overrides["crops.soil"] = "broken"
	resolver.set_theme("halloween")
	check(resolver.resolve("plot.test","crops.soil").key=="crops.soil","Missing asset resolves declared fallback")
	var timer = preload("res://scripts/visual/appearance/animation_clock.gd")
	for hz in [30,60,120]:
		var time: float = 0
		for i in range(hz*2): time += 1.0/hz
		check(timer.frame([0.2,0.3,0.7],time,"cow")==timer.frame([0.2,0.3,0.7],2.0,"cow"),"Animation seconds independent of frame rate")
	var time := Base.ControlledTime.new()
	var store := Base.MemoryStore.new()
	var farm := Service.new(Clock.new(time.now,1,"appearance.test"),store,func() -> float: return 1)
	check(farm.load_farm(farm.fixture()),"Farm opens")
	check(farm.state.plots.size()==16,"Capacity sixteen, four initially available")
	var viewport := SubViewport.new(); viewport.size = Vector2i(1080,1920); root.add_child(viewport)
	var scene = load("res://scenes/main/farm.tscn").instantiate()
	scene.preferences_path = "res://../.local/visual_v2/qa_preferences.cfg"
	scene.injected_service = farm; viewport.add_child(scene)
	await process_frame
	scene.world.set_theme("halloween"); scene.world.set_skin("building.house","house.sky"); scene.save_preferences()
	scene.world.set_theme("standard"); scene.world.set_skin("building.house",""); scene.load_preferences()
	check(scene.world.appearance.theme=="halloween" and scene.world.appearance.skins.get("building.house")=="house.sky","Theme and individual skin persist through real preferences IO")
	var world_id: int = scene.world.get_instance_id()
	for theme in ["standard","halloween","standard"]:
		var before := JSON.stringify(farm.snapshot())
		scene.world.set_theme(theme); scene.world.set_skin("building.house","house.sky")
		check(JSON.stringify(farm.snapshot())==before and world_id==scene.world.get_instance_id(),"Cosmetics preserve economic snapshot and scene")
		var planted: Dictionary = farm.execute({"type":"plant","plot_id":"plot.home.a","crop_id":"crop.carrot","request_id":"plant."+theme+str(checks)})
		check(planted.ok,"Plant after theme change")
		time.value += 140
		scene.world.intensity = 0; scene.demo.refresh()
		var cmd := {"type":"harvest","plot_id":"plot.home.a","cycle_id":planted.get("cycle_id",""),"request_id":"harvest."+str(checks)}
		check(farm.execute(cmd).ok,"Harvest with effects disabled")
		var products: int = farm.state.inventory.products["crop.carrot"]
		check(farm.execute(cmd).get("replayed",false) and products==farm.state.inventory.products["crop.carrot"],"Theme cannot duplicate rewards")
	var reopened := Service.new(Clock.new(time.now,1,"appearance.test"),store)
	check(reopened.load_farm(reopened.fixture()) and reopened.state==farm.state,"Persistence survives cosmetics and harvest")
	viewport.queue_free(); await process_frame; await create_timer(0.2).timeout
	# Real eight-plot save, populated with active crop, extends without changing old plots/ledger.
	var old := preload("res://scripts/services/cultures/local_culture_service.gd").new(Clock.new(time.now,1,"legacy"),Base.MemoryStore.new())
	old.load_farm(old.fixture())
	old.execute({"type":"plant","plot_id":"plot.home.a","crop_id":"crop.carrot","request_id":"legacy.plant"})
	var target := Service.new(Clock.new(time.now,1,"appearance.test"),Base.MemoryStore.new())
	var converted: Dictionary = preload("res://scripts/domain/integrated/save_migration.gd").convert(old.state,false,target)
	var old_plots: Dictionary = converted.state.plots.duplicate(true)
	var memory := Base.MemoryStore.new(); memory.data = converted.state
	var failed := Base.MemoryStore.new(); failed.data = converted.state.duplicate(true); failed.fail_write = true
	var refused := Service.new(Clock.new(time.now,1,"appearance.test"),failed)
	check(not refused.load_farm(refused.fixture()) and failed.data.plots.size()==8 and refused.state.is_empty(),"Failed capacity write does not publish migration")
	var migrated := Service.new(Clock.new(time.now,1,"appearance.test"),memory)
	check(migrated.load_farm(migrated.fixture()),"Legacy capacity migrates")
	check(migrated.state.plots.size()==16 and migrated.state.economy.coins==converted.state.economy.coins,"No migration economic grant")
	for id in old_plots: check(migrated.state.plots[id]==old_plots[id],"Old plot preserved: "+id)
	var revision: int = migrated.state.revision
	check(migrated.load_farm(migrated.fixture()) and migrated.state.revision==revision,"Migration is idempotent")
	print("Appearance checks: %d; failures: %d"%[checks,failures])
	quit(1 if failures else 0)
