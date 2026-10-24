extends SceneTree

const Service = preload("res://scripts/services/farming/local_farm_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
const Rules = preload("res://scripts/domain/farming/growth_rules.gd")
var checks: int = 0
var failures: int = 0
var serial: int = 0
var files: Array[String] = []

class ControlledTime:
	extends RefCounted
	var value: float = 1000
	func now() -> float:
		return value

class MemoryStore:
	extends RefCounted
	var data: Dictionary = {}
	var error: String = ""
	var fail_write: bool = false
	func read() -> Dictionary:
		return {"ok":true,"missing":data.is_empty(),"state":data.duplicate(true)}
	func commit(next: Dictionary, expected: int) -> bool:
		if fail_write or (not data.is_empty() and int(data.revision)!=expected):
			error = "injected_write_failure"
			return false
		data = next.duplicate(true)
		return true

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func fixture() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))

func request(type: String, id: String = "plot.0.0", crop: String = "crop.carrot", cycle: String = "") -> Dictionary:
	serial += 1
	return {"request_id":"test."+str(serial),"type":type,"plot_id":id,"crop_id":crop,"cycle_id":cycle}

func service(time: ControlledTime, storage: RefCounted = null, layout: Dictionary = {}) -> RefCounted:
	var value := Service.new(Clock.new(time.now),MemoryStore.new() if storage==null else storage)
	check(value.load_farm(fixture() if layout.is_empty() else layout),"Service loads valid versioned fixture")
	return value

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var time := ControlledTime.new()
	var farm = service(time)
	check(farm.catalog.ids.size()==3 and farm.catalog.error.is_empty(),"Three valid data-driven crops")
	var events: Array = []
	farm.event_emitted.connect(func(event: Dictionary) -> void: events.append(event))
	var command := request("plant")
	var result: Dictionary = farm.execute(command)
	check(result.ok,"Plant valid empty plot")
	check(farm.state.inventory.seeds["crop.carrot"]==11,"One seed consumed")
	var cycle: String = result.cycle_id
	check(farm.state.plots["plot.0.0"].ready_at==1120,"Ready timestamp frozen at planting")
	check(farm.execute(command).get("replayed",false),"Duplicate planting request replays receipt")
	check(farm.state.inventory.seeds["crop.carrot"]==11,"Retry never consumes twice")
	check(not farm.execute(request("plant")).ok,"Occupied plot cannot be replanted")
	command.crop_id = "crop.wheat"
	check(farm.execute(command).error=="request_id_conflict","Same request with different intent rejected")
	time.value = 1041.999
	check(farm.snapshot().plots["plot.0.0"].growth.stage==0,"Before exact stage boundary")
	time.value = 1042
	check(farm.snapshot().plots["plot.0.0"].growth.stage==1,"Exact stage boundary")
	time.value = 1119.999
	check(farm.execute(request("harvest","plot.0.0","",cycle)).error=="not_mature","Harvest before maturity rejected")
	time.value = 1120
	check(farm.snapshot().plots["plot.0.0"].state=="mature","Exact maturity boundary, without ticks")
	var harvest := request("harvest","plot.0.0","",cycle)
	check(farm.execute(harvest).ok,"Harvest at maturity")
	check(farm.state.inventory.products["crop.carrot"]==2,"Product quantity credited")
	check(farm.execute(harvest).get("replayed",false),"Duplicate harvest receipt")
	check(not farm.execute(request("harvest","plot.0.0","",cycle)).ok,"Different request cannot reharvest same cycle")
	check(farm.state.inventory.products["crop.carrot"]==2,"No duplicate rewards")
	check(events.size()==2,"Analytics hook only emits committed fresh actions")
	check(farm.execute(request("plant")).ok,"Replant creates new cycle")
	check(farm.state.plots["plot.0.0"].cycle_id!=cycle,"Persistent cycle sequence advances")
	check(not farm.execute(request("harvest","plot.0.0","",cycle)).ok,"Stale cycle cannot harvest new crop")
	var detached: Dictionary = farm.snapshot()
	detached.inventory.seeds["crop.carrot"] = 999
	check(farm.state.inventory.seeds["crop.carrot"]==10,"Read snapshot does not expose mutable inventory")
	check(not farm.execute(request("plant","missing")).ok,"Unknown plot")
	check(not farm.execute(request("plant","plot.3.0","missing")).ok,"Unknown crop")
	check(farm.execute(request("fertilize")).error=="feature_not_enabled","Fertilizer runtime not enabled in G1.1")
	for crop_id in farm.catalog.ids:
		var stage_time := ControlledTime.new()
		var staged = service(stage_time)
		staged.execute(request("plant","plot.0.0",crop_id))
		var crop: Dictionary = staged.catalog.entries[crop_id]
		for i in range(crop.stages.size()):
			stage_time.value = 1000+float(crop.growth_seconds)*float(crop.stages[i].at)
			check(staged.snapshot().plots["plot.0.0"].growth.stage==i,"Exact stage boundary for "+crop_id)
		stage_time.value += 365*86400
		check(staged.snapshot().plots["plot.0.0"].state=="mature","Mature crop never expires in G1.1")
	var layout := fixture()
	layout.initial_seeds["crop.carrot"] = 0
	layout.plots[1].locked = true
	var limited = service(time,null,layout)
	check(limited.execute(request("plant")).error=="no_seeds","No negative seed balances")
	check(limited.execute(request("plant","plot.3.0")).error=="plot_locked","Locked plots reject actions")
	var memory := MemoryStore.new()
	var failing = service(time,memory)
	memory.fail_write = true
	check(not failing.execute(request("plant")).ok,"Failed persistence denies action")
	check(failing.state.inventory.seeds["crop.carrot"]==12 and failing.state.plots["plot.0.0"].crop_id.is_empty(),"Write failure rolls back all in-memory effects")
	await disk_tests(time)
	fertilizer_tests()
	await scene_tests()
	for file in files:
		DirAccess.remove_absolute(file)
		DirAccess.remove_absolute(file+".tmp")
	print("G1.1 farming checks: %d; failures: %d"%[checks,failures])
	quit(0 if failures==0 else 1)

func disk_tests(time: ControlledTime) -> void:
	var folder := ProjectSettings.globalize_path("res://../.local/g11/tests")
	DirAccess.make_dir_recursive_absolute(folder)
	var path := folder.path_join("farm_"+str(OS.get_process_id())+".json")
	files.append(path)
	var first = service(time,Store.new(path))
	var stale = service(time,Store.new(path))
	var plant: Dictionary = first.execute(request("plant","plot.0.0","crop.wheat"))
	check(plant.ok,"Real disk planting commit")
	check(not stale.execute(request("plant","plot.3.0")).ok,"Stale local instance detects revision conflict")
	check(stale.state.inventory.seeds["crop.carrot"]==12,"Conflict does not consume inventory")
	time.value += 30*86400
	var reopened = service(time,Store.new(path))
	check(reopened.snapshot().plots["plot.0.0"].state=="mature","Reopen after long absence derives maturity")
	check(reopened.state.inventory.seeds["crop.wheat"]==11,"Seed deduction persisted")
	var command := request("harvest","plot.0.0","",plant.cycle_id)
	check(reopened.execute(command).ok,"Harvest persisted crop after reopen")
	var again = service(time,Store.new(path))
	check(again.state.inventory.products["crop.wheat"]==4,"Products survive service restart")
	check(again.execute(command).get("replayed",false) and again.state.inventory.products["crop.wheat"]==4,"Receipt survives restart without duplicate product")
	var wrong_profile := Service.new(Clock.new(time.now,60,"local.fast60.v1"),Store.new(path))
	check(not wrong_profile.load_farm(fixture()),"Clock profiles cannot cross-load")
	var corrupt := path+".corrupt.json"
	files.append(corrupt)
	var file := FileAccess.open(corrupt,FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	var broken := Service.new(Clock.new(time.now),Store.new(corrupt))
	check(not broken.load_farm(fixture()) and broken.state.is_empty(),"Corrupt save fails closed without free reset")
	check(FileAccess.get_file_as_string(corrupt)=="{broken","Corrupt file left intact")
	file = FileAccess.open(corrupt,FileAccess.WRITE)
	var invalid: Dictionary = first.state.duplicate(true)
	invalid.schema_version = 99
	file.store_string(JSON.stringify(invalid))
	file.close()
	check(not broken.load_farm(fixture()),"Unsupported schema rejected")
	var expanded := fixture()
	for i in range(32):
		expanded.plots.append({"id":"plot.future."+str(i),"grid":[20+i*2,0],"region_id":"future","locked":true})
	check(service(time,null,expanded).snapshot().plots.size()==36,"Model has no 4/16 plot ceiling")
	check(Clock.new(time.now,60,"local.fast60.v1").now_seconds()==time.value*60,"Fast testing profile uses elapsed wall time, not frames")
	var fast_store := MemoryStore.new()
	var fast_time := ControlledTime.new()
	var fast := Service.new(Clock.new(fast_time.now,60,"local.fast60.v1"),fast_store)
	check(fast.load_farm(fixture()),"Accelerated profile initializes separately")
	fast.execute(request("plant"))
	fast_time.value += 2
	var fast_reopened := Service.new(Clock.new(fast_time.now,60,"local.fast60.v1"),fast_store)
	check(fast_reopened.load_farm(fixture()) and fast_reopened.snapshot().plots["plot.0.0"].state=="mature","Accelerated offline clock survives reinitialization")
	var process_path := folder.path_join("restart_"+str(OS.get_process_id())+".json")
	files.append(process_path)
	for phase in ["plant","harvest","replay"]:
		var output: Array = []
		var code := OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/farming_restart_probe.gd","--",phase,process_path],output,true)
		check(code==0,"Separate process "+phase+" persists once across sessions: "+str(output))

func fertilizer_tests() -> void:
	var time := ControlledTime.new()
	var farm = service(time)
	farm.execute(request("plant"))
	var plot: Dictionary = farm.state.plots["plot.0.0"].duplicate(true)
	var crop: Dictionary = farm.catalog.entries["crop.carrot"]
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/fertilizers.json"))
	check(config.items.size()==4,"Four future fertilizer classes")
	check(not Rules.preview_fertilizer(plot,crop,config.items[0],config.limits,1001,"f1","owner").ok,"Unbalanced nulls never grant acceleration")
	var item := {"id":"fertilizer.common","scope":"owner","reduction_fraction":0.25}
	var limits := {"max_total_acceleration":0.5,"minimum_growth_seconds":10,"max_uses_per_cycle":2}
	var proposal := Rules.preview_fertilizer(plot,crop,item,limits,1001,"f1","owner")
	check(proposal.ok and proposal.ready_at==1090,"Pure preview uses configurable bounded acceleration")
	check(plot.ready_at==1120 and plot.modifiers.is_empty(),"Preview never mutates cultivation")
	plot.ready_at = proposal.ready_at
	plot.modifiers.append(proposal.history)
	check(Rules.preview_fertilizer(plot,crop,item,limits,1001,"f1","owner").error=="duplicate_modifier","Duplicate modifier history rejected")
	check(not Rules.preview_fertilizer(plot,crop,item,limits,1001,"f2","friend").ok,"Social scope restricted")
	item.id = "unknown"
	check(not Rules.preview_fertilizer(plot,crop,item,limits,1001,"f2","owner").ok,"Crop compatibility restricted")
	item.id = "fertilizer.common"
	proposal = Rules.preview_fertilizer(plot,crop,item,limits,1085,"f2","owner")
	check(not proposal.ok,"Cannot instant-complete near maturity")
	proposal = Rules.preview_fertilizer(plot,crop,item,limits,1001,"f2","owner")
	check(proposal.ok and proposal.ready_at>=1060,"Total acceleration floor")
	plot.modifiers.append(proposal.history)
	check(not Rules.preview_fertilizer(plot,crop,item,limits,1001,"f3","owner").ok,"Per-cycle use cap")

func touch(viewport: SubViewport, point: Vector2, pressed: bool, index: int = 0) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = pressed
	event.index = index
	viewport.push_input(event,true)

func center(scene: Control, id: int) -> Vector2:
	return scene.container.position+(scene.world.position+scene.world.plot_center(id)-Vector2(0,8))*scene.zoom

func scene_tests() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var time := ControlledTime.new()
		var farm = service(time)
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g11/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		await process_frame
		for i in range(3):
			scene.select_seed(i)
			var point := center(scene,i)
			touch(viewport,point,true)
			touch(viewport,point,false)
			check(not scene.demo.plots[i].crop_id.is_empty(),"Touch plants each of three cultures")
			time.value += float(farm.catalog.entries[farm.catalog.ids[i]].growth_seconds)
			scene.demo.refresh()
			check(scene.demo.plots[i].state=="mature","Visual state derived from controlled time")
			touch(viewport,point,true)
			touch(viewport,point,false)
			check(int(farm.state.inventory.products.get(farm.catalog.ids[i],0))>0,"Touch harvest credits actual inventory")
		var planted: Dictionary = farm.execute(request("plant",scene.demo.plot_ids[0]))
		check(planted.ok,"Set mixed drag fixture")
		time.value += 121
		scene.demo.refresh()
		var point := center(scene,0)
		touch(viewport,point,true)
		var drag := InputEventScreenDrag.new()
		drag.position = center(scene,1)
		viewport.push_input(drag,true)
		touch(viewport,drag.position,false)
		check(scene.demo.plots[0].state=="empty" and scene.demo.plots[1].state=="empty","Harvest drag never plants an empty neighbor")
		var revision: int = farm.state.revision
		touch(viewport,point,true,0)
		touch(viewport,center(scene,1),true,1)
		touch(viewport,center(scene,1),false,1)
		touch(viewport,point,false,0)
		check(farm.state.revision==revision,"Pinch cannot mutate crops")
		scene.choose("camera")
		var previous: Vector2 = scene.camera
		scene.gesture.press(point)
		scene.gesture.move(point+Vector2(60,0))
		scene.gesture.release(point+Vector2(60,0))
		check(scene.camera!=previous and farm.state.revision==revision,"Camera isolated from farming")
		scene.frame_camera()
		scene.select_seed(0)
		point = center(scene,3)
		for down in [true,false]:
			var mouse := InputEventMouseButton.new()
			mouse.position = point
			mouse.button_index = MOUSE_BUTTON_LEFT
			mouse.pressed = down
			viewport.push_input(mouse,true)
		check(scene.demo.plots[3].state=="planted","Actual viewport mouse planting route")
		revision = farm.state.revision
		touch(viewport,point,true)
		scene.gesture.tick(0.56)
		touch(viewport,point,false)
		check(farm.state.revision==revision,"Long touch inspects without modifying")
		var key := InputEventKey.new()
		key.keycode = KEY_3
		key.pressed = true
		viewport.push_input(key,true)
		check(scene.demo.tool=="camera","Keyboard camera tool")
		scene.open_inventory()
		await process_frame
		check(scene.hit_at(point)==-1,"Inventory blocks background actions")
		for node in scene.panel.find_children("*","Button",true,false):
			check(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(node.get_global_rect()),"Inventory buttons fit desktop and portrait")
		viewport.queue_free()
		await process_frame
