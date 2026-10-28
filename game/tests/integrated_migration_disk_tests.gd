extends SceneTree
const Base = preload("res://tests/farming_tests.gd")
const Old = preload("res://scripts/services/cultures/local_culture_service.gd")
const Service = preload("res://scripts/services/integrated/farm_service.gd")
const Clock = preload("res://scripts/services/cultures/culture_clock.gd")
const Store = preload("res://scripts/services/farming/farm_store.gd")
func _initialize() -> void:
	var folder := ProjectSettings.globalize_path("res://../.local/integrated/migration")
	DirAccess.make_dir_recursive_absolute(folder)
	var source := folder.path_join("source_"+str(OS.get_process_id())+".json")
	var target := source+".integrated.json"
	var time := Base.ControlledTime.new()
	var old := Old.new(Clock.new(time.now,1,"local.cultures.real.v5"),Base.MemoryStore.new())
	if not old.load_farm(old.fixture()): quit(1); return
	old.execute({"type":"plant","plot_id":"plot.home.a","crop_id":"crop.carrot","request_id":"prior.plant"})
	var file := FileAccess.open(source,FileAccess.WRITE); file.store_string(JSON.stringify(old.state)); file.close()
	var raw := FileAccess.get_file_as_string(source)
	var output: Array = []
	var args := ["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tests/import_integrated_save.gd","--",source,target,"normal"]
	var code := OS.execute(OS.get_executable_path(),args,output,true)
	if code!=0 or FileAccess.get_file_as_string(source)!=raw: push_error("Copy import failed: "+str(output)); quit(1); return
	var farm := Service.new(Clock.new(time.now,1,"integrated.real.v1"),Store.new(target))
	if not farm.load_farm(farm.fixture()) or farm.state.plots["plot.home.a"].ready_at!=old.state.plots["plot.home.a"].ready_at: push_error("Imported save failed to open"); quit(1); return
	var prior := FileAccess.get_file_as_string(target)
	output.clear(); code = OS.execute(OS.get_executable_path(),args,output,true)
	if code==0 or FileAccess.get_file_as_string(target)!=prior: push_error("Overwrite protection failed"); quit(1); return
	print("Integrated disk migration PASS: actual subprocess, original bytes/timers preserved, existing target refused")
	quit()
