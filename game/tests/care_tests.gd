extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Service = preload("res://scripts/services/care/local_care_service.gd")
const Clock = preload("res://scripts/services/farming/farm_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
var checks: int = 0
var failures: int = 0
var serial: int = 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func fixture() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/farm_fixture.json"))

func make(time: RefCounted, store: RefCounted = null, roll: float = 0) -> RefCounted:
	var farm := Service.new(Clock.new(time.now),Base.MemoryStore.new() if store==null else store,func() -> float: return roll)
	check(farm.load_farm(fixture()),"Load schema2 care farm")
	return farm

func command(farm: RefCounted, type: String, id: String = "plot.0.0", item: String = "fertilizer.common", crop: String = "crop.wheat", ack: bool = false) -> Dictionary:
	serial += 1
	return {"request_id":"care."+str(serial),"type":type,"plot_id":id,"crop_id":crop,"cycle_id":farm.state.plots[id].cycle_id,"item_id":item,"rare_ack":ack}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var time = Base.ControlledTime.new()
	var farm = make(time)
	check(farm.execute(command(farm,"plant")).ok,"Plant with persistent care schedule")
	var cycle: String = farm.state.plots["plot.0.0"].cycle_id
	var water := command(farm,"water")
	check(farm.execute(water).ok,"Valid direct watering")
	check(farm.state.plots["plot.0.0"].ready_at==7840,"Water saves exactly five percent of base duration")
	check(farm.snapshot().plots["plot.0.0"].growth.care.hydrated,"Hydration is derived from timestamp")
	check(farm.execute(water).get("replayed",false),"Water retry replays without second benefit")
	check(farm.execute(command(farm,"water")).error=="water_not_needed","Repeated water blocked")
	check(farm.state.plots["plot.0.0"].care.history.size()==1,"No duplicate care history")
	check(not farm.execute(command(farm,"remove_pests")).ok,"Wrong tool/no pest blocked")
	var foreign := command(farm,"water")
	foreign.actor_id = "future.friend"
	check(farm.execute(foreign).error=="foreign_actor","No unauthorized social application exposed")
	time.value = 3520
	var status: Dictionary = farm.snapshot().plots["plot.0.0"].growth.care
	check(status.weeds and status.pests,"Both nuisances become active by elapsed time")
	check(is_equal_approx(status.delay_seconds,432),"Moderate penalty capped at six percent")
	check(farm.execute(command(farm,"remove_weeds")).ok,"Remove active weeds")
	check(farm.execute(command(farm,"remove_pests")).ok,"Remove active pests")
	check(not farm.snapshot().plots["plot.0.0"].growth.care.pests,"Pests removed from view")
	check(farm.snapshot().plots["plot.0.0"].growth.care.delay_seconds==0,"Removal fully recovers nuisance delay")
	time.value += 86400*30
	check(farm.snapshot().plots["plot.0.0"].state=="mature","Absence never kills crop")
	check(not farm.snapshot().plots["plot.0.0"].growth.care.weeds,"Removed nuisance never respawns in same cycle")
	var harvest := command(farm,"harvest")
	check(farm.execute(harvest).ok,"Harvest after absence")
	check(farm.state.inventory.products["crop.wheat"]==4,"No destructive yield penalty")
	check(farm.execute(harvest).get("replayed",false),"Harvest receipt still idempotent")
	check(farm.state.inventory.products["crop.wheat"]==4,"No duplicate reward")
	check(farm.state.receipts[harvest.request_id].result.care_history.size()==3,"Completed cycle preserves care history in receipt")
	check(cycle==farm.state.receipts[harvest.request_id].result.cycle_id,"Cycle audit identity preserved")
	fertilizer_tests()
	frequency_tests()
	persistence_tests()
	await scene_tests()
	print("G1.2 care checks: %d; failures: %d"%[checks,failures])
	quit(0 if failures==0 else 1)

func fertilizer_tests() -> void:
	var time = Base.ControlledTime.new()
	var farm = make(time,null,1)
	farm.execute(command(farm,"plant"))
	var initial: float = farm.state.plots["plot.0.0"].ready_at
	var fertilize := command(farm,"fertilize")
	check(farm.execute(fertilize).ok,"Functional common fertilizer")
	check(farm.state.plots["plot.0.0"].ready_at==7480,"Ten percent of remaining time reduced")
	check(farm.state.inventory.fertilizers["fertilizer.common"]==7,"One fertilizer consumed")
	check(farm.execute(fertilize).get("replayed",false),"Fertilizer retry does not consume again")
	check(farm.state.inventory.fertilizers["fertilizer.common"]==7,"Fertilizer stock stable on replay")
	check(farm.execute(command(farm,"fertilize")).ok,"Second common use")
	check(farm.execute(command(farm,"fertilize")).error=="fertilizer_use_limit","Per-item per-cycle cap")
	check(farm.execute(command(farm,"fertilize","plot.0.0","fertilizer.super")).error=="fertilizer_incompatible","Super incompatible with wheat")
	check(farm.execute(command(farm,"fertilize","plot.0.0","fertilizer.social")).error=="social_not_available","Love prepared, social gate blocked")
	check(farm.execute(command(farm,"fertilize","plot.0.0","unknown")).error=="unknown_fertilizer","Unknown item rejected")
	check(farm.execute(command(farm,"fertilize","plot.0.0","fertilizer.fast")).ok,"Fast fertilizer usable")
	check(float(farm.state.plots["plot.0.0"].ready_at)>=1000+7200*0.5,"Combined acceleration floor")
	check(float(farm.state.plots["plot.0.0"].ready_at)<initial,"Acceleration persists in authoritative candidate")
	var ready: float = farm.state.plots["plot.0.0"].ready_at
	time.value = ready
	check(farm.execute(command(farm,"harvest")).ok,"Harvest exactly after accelerated maturity")
	var rare = make(time,null,1)
	rare.execute(command(rare,"plant","plot.0.0","","crop.carrot"))
	check(rare.execute(command(rare,"fertilize","plot.0.0","fertilizer.super")).error=="rare_arm_required","Rare consumable protected until explicit arm")
	check(rare.execute(command(rare,"fertilize","plot.0.0","fertilizer.super","crop.carrot",true)).ok,"One explicitly armed super use")
	check(rare.state.inventory.fertilizers["fertilizer.super"]==0,"Super consumed once")
	rare.execute(command(rare,"plant","plot.3.0","","crop.carrot"))
	check(rare.execute(command(rare,"fertilize","plot.3.0","fertilizer.super","crop.carrot",true)).error=="no_fertilizer_stock","No stock cannot grant acceleration")
	var late = make(time,null,1)
	late.execute(command(late,"plant","plot.0.0","","crop.carrot"))
	time.value += 115
	check(late.execute(command(late,"fertilize")).error=="acceleration_limit","No near-instant/negative growth from late fertilizer")
	check(late.state.inventory.fertilizers["fertilizer.common"]==8,"Invalid application never consumes")
	var invalid = make(time)
	invalid.items["fertilizer.common"].reduction_fraction = -1
	check(not invalid.load_farm(fixture()),"Invalid data-driven fertilizer effect rejected")
	var memory = Base.MemoryStore.new()
	var failing = make(time,memory,1)
	failing.execute(command(failing,"plant"))
	memory.fail_write = true
	check(not failing.execute(command(failing,"fertilize")).ok,"Failed commit rejects fertilizer")
	check(failing.state.inventory.fertilizers["fertilizer.common"]==8 and failing.state.plots["plot.0.0"].modifiers.is_empty(),"Failed IO rolls back modifier and stock together")

func frequency_tests() -> void:
	var time = Base.ControlledTime.new()
	var farm = make(time,null,1)
	farm.policy.crops["crop.wheat"].hydration_seconds = 10
	farm.policy.crops["crop.wheat"].water_cooldown = 60
	farm.execute(command(farm,"plant"))
	farm.execute(command(farm,"water"))
	time.value += 11
	check(farm.execute(command(farm,"water")).error=="water_cooldown","Water frequency cooldown enforced")
	time.value += 49
	check(farm.execute(command(farm,"water")).ok,"Water exact cooldown boundary")
	time.value += 61
	check(farm.execute(command(farm,"water")).error=="water_use_limit","No unlimited water acceleration")
	var quiet = make(time,null,1)
	quiet.execute(command(quiet,"plant"))
	time.value += 100000
	var status: Dictionary = quiet.snapshot().plots["plot.0.0"].growth.care
	check(not status.weeds and not status.pests,"Probability roll outside configured chance produces none")
	var active = make(time,null,0)
	active.execute(command(active,"plant","plot.0.0","","crop.carrot"))
	time.value += 23.999
	check(not active.snapshot().plots["plot.0.0"].growth.care.weeds,"Before exact nuisance boundary")
	time.value += 0.0011
	check(active.snapshot().plots["plot.0.0"].growth.care.weeds,"Nuisance at configured threshold")
	active.execute(command(active,"remove_weeds"))
	check(active.execute(command(active,"remove_weeds")).error=="nuisance_not_present","No repeated recovery credit")

func persistence_tests() -> void:
	var folder := ProjectSettings.globalize_path("res://../.local/g12/tests")
	DirAccess.make_dir_recursive_absolute(folder)
	var path := folder.path_join("care_"+str(OS.get_process_id())+".json")
	var time = Base.ControlledTime.new()
	var farm = make(time,Store.new(path),0)
	farm.execute(command(farm,"plant"))
	farm.execute(command(farm,"water"))
	var apply := command(farm,"fertilize")
	farm.execute(apply)
	time.value += 2600
	var reopened = make(time,Store.new(path),1)
	check(reopened.state.inventory.fertilizers["fertilizer.common"]==7,"Fertilizer stock survives restart")
	check(reopened.snapshot().plots["plot.0.0"].growth.care.pests,"Scheduled pests persist without reroll")
	check(reopened.state.plots["plot.0.0"].care.watered_at==1000,"Hydration timestamp persists")
	check(reopened.execute(apply).get("replayed",false),"Consumed fertilizer receipt persists")
	check(reopened.state.inventory.fertilizers["fertilizer.common"]==7,"Restart cannot duplicate fertilizer effect")
	check(reopened.state.plots["plot.0.0"].modifiers.size()==1,"One persisted time modification")
	reopened.execute(command(reopened,"remove_pests"))
	var again = make(time,Store.new(path),0)
	check(not again.snapshot().plots["plot.0.0"].growth.care.pests,"Removal persists across reopening")
	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(path+".tmp")
	var process_path := folder.path_join("restart_"+str(OS.get_process_id())+".json")
	for phase in ["plant","care","harvest","replay"]:
		var output: Array = []
		var code := OS.execute(OS.get_executable_path(),["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/care_restart_probe.gd","--",phase,process_path],output,true)
		check(code==0,"Separate care process "+phase+": "+str(output))
	DirAccess.remove_absolute(process_path)
	DirAccess.remove_absolute(process_path+".tmp")

func touch(viewport: SubViewport, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = pressed
	viewport.push_input(event,true)

func center(scene: Control, id: int) -> Vector2:
	return scene.container.position+(scene.world.position+scene.world.plot_center(id)-Vector2(0,8))*scene.zoom

func scene_tests() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920),Vector2i(1280,720),Vector2i(720,1280)]:
		var time = Base.ControlledTime.new()
		var farm = make(time,null,0)
		for id in farm.state.plots:
			farm.execute(command(farm,"plant",id))
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/farm/g12/farm.tscn").instantiate()
		scene.injected_service = farm
		viewport.add_child(scene)
		await process_frame
		for id in scene.world.care_art:
			if id=="status":
				continue
			var r: Array = scene.world.care_art[id].rect
			check(Rect2(Vector2.ZERO,scene.world.CARE.get_size()).encloses(Rect2(r[0],r[1],r[2],r[3])),"Care sprite region stays inside source atlas")
		scene.select_care("water")
		var point := center(scene,0)
		touch(viewport,point,true)
		var drag := InputEventScreenDrag.new()
		drag.position = center(scene,1)
		viewport.push_input(drag,true)
		touch(viewport,drag.position,false)
		check(scene.demo.plots[0].care.hydrated and scene.demo.plots[1].care.hydrated,"Water drag applies care to multiple plots")
		var revision: int = farm.state.revision
		touch(viewport,point,true)
		scene.gesture.tick(0.56)
		touch(viewport,point,false)
		scene.update_context()
		check(scene.context_card.visible and "Falta" in scene.context_card.text.text and "Trigo" in scene.context_card.text.text,"Long touch shows contextual crop and remaining time")
		check(farm.state.revision==revision,"Long touch never spends consumable")
		check(scene.area.encloses(scene.context_card.get_global_rect()),"Context card fits useful map rectangle")
		var mouse := InputEventMouseMotion.new()
		mouse.position = center(scene,2)
		viewport.push_input(mouse,true)
		scene.update_context()
		check(scene.context_card.visible,"Hover discovers contextual timer")
		scene.open_care_tools()
		await process_frame
		for button in scene.panel.find_children("*","Button",true,false):
			check(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(button.get_global_rect()),"Care tools fit PC and portrait")
		check(scene.hit_at(point)==-1,"Care menu blocks farm input")
		scene.select_care("fertilizer.super")
		check(scene.demo.rare_armed,"Selecting super explicitly arms one use")
		farm.items["fertilizer.super"].compatible_crops.append("crop.wheat")
		touch(viewport,center(scene,2),true)
		drag.position = center(scene,3)
		viewport.push_input(drag,true)
		touch(viewport,drag.position,false)
		check(farm.state.inventory.fertilizers["fertilizer.super"]==0 and farm.state.plots[scene.demo.plot_ids[3]].modifiers.is_empty(),"Rare drag consumes only one explicitly armed application")
		check(not scene.demo.rare_armed,"Rare item automatically disarmed after success")
		scene.select_care("water")
		check(not scene.demo.rare_armed,"Changing tool disarms rare consumable")
		viewport.queue_free()
		await process_frame
