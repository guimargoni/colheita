extends SceneTree

var checks: int = 0
var failures: int = 0

func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(description)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var model = load("res://scripts/prototype/local_garden.gd").new()
	check(model.act(0)=="harvest", "Direct harvest")
	check(model.act(0)=="plant", "Direct plant")
	check(model.act(0)=="", "Wrong tool cannot water")
	model.tool = "water"
	check(model.act(0)=="water", "Direct water")
	model.tick(10)
	check(model.plots[0].state=="mature", "Demo growth")
	model.tool = "camera"
	check(model.act(0)=="", "Camera cannot harvest")
	var gesture = load("res://scripts/prototype/garden_gesture.gd").new()
	gesture.picker = func(p: Vector2) -> int: return int(p.x/50) if p.y<100 else -1
	var actions: Array[int] = []
	gesture.action_requested.connect(func(id: int) -> void: actions.append(id))
	gesture.press(Vector2(10,10))
	gesture.move(Vector2(140,10))
	gesture.move(Vector2(10,10))
	gesture.release(Vector2(10,10))
	check(actions==[0,1,2], "Fast drag visits each plot once")
	actions.clear()
	gesture.press(Vector2(10,10),0)
	gesture.press(Vector2(80,10),1)
	gesture.move(Vector2(100,10),1)
	gesture.release(Vector2(100,10),1)
	gesture.release(Vector2(10,10),0)
	check(actions.is_empty(), "Pinch never acts")
	gesture.press(Vector2(10,10))
	gesture.tick(0.6)
	gesture.release(Vector2(10,10))
	check(actions.is_empty(), "Long press only inspects")
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/experience/experience.tscn").instantiate()
		viewport.add_child(scene)
		await process_frame
		var point: Vector2 = scene.world.to_global(scene.world.project(Vector2(3.14,3.44))-Vector2(0,9))
		check(scene.hit_at(point)==0,"Scene hit matches drawing")
		for pressed in [true,false]:
			var event := InputEventScreenTouch.new()
			event.position = point
			event.pressed = pressed
			viewport.push_input(event,true)
		check(scene.demo.plots[0].state=="empty","Touch routed through viewport")
		scene.open_panel("Configurações")
		check(scene.hit_at(point)==-1,"Modal blocks map")
		viewport.queue_free()
		await process_frame
	print("G0.4 checks: %d; failures: %d" % [checks,failures])
	await create_timer(0.3).timeout
	quit(0 if failures==0 else 1)
