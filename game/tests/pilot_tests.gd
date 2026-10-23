extends SceneTree

var checks: int = 0
var failures: int = 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func controls(node: Node) -> Array[Button]:
	var result: Array[Button] = []
	for child in node.get_children():
		if child is Button:
			result.append(child)
		result.append_array(controls(child))
	return result

func touch(viewport: SubViewport, point: Vector2, down: bool, index: int = 0) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = down
	event.index = index
	viewport.push_input(event,true)

func center(scene: Control, id: int) -> Vector2:
	return scene.container.position+(scene.world.position+scene.world.plot_center(id)-Vector2(0,8))*scene.zoom

func run() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/art/pilot/pilot.tscn").instantiate()
		viewport.add_child(scene)
		await process_frame
		scene.set_process(false)
		check(scene.demo.plots.size()==4,"Only four plots; no farm expansion")
		check(scene.world.position==scene.world.position.round(),"Source-pixel camera snapping")
		check(scene.container.scale.x==int(scene.container.scale.x),"Integer presentation")
		check(scene.area.size.y/resolution.y>=0.67,"Map retains useful screen area")
		for family in ["env","crops"]:
			var texture = scene.world.ENV if family=="env" else scene.world.CROPS
			for key in scene.world.definition[family]:
				var item: Dictionary = scene.world.definition[family][key]
				if family=="env":
					texture = scene.world.TREE if key=="tree" else scene.world.ENV
				var r: Array = item.rect
				check(r[0]>=0 and r[1]>=0 and r[0]+r[2]<=texture.get_width() and r[1]+r[3]<=texture.get_height(),"Source rectangle inside original PNG")
				check(item.size[0]>0 and item.size[1]>0,"Fixed nonzero logical size")
		for id in range(4):
			check(scene.hit_at(center(scene,id))==id,"Artwork and hit center agree")
		var buttons := controls(scene.hud)
		for button in buttons:
			check(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(button.get_global_rect()),"HUD button fits screen")
			if scene.portrait:
				check(button.size.y>=144 and button.size.x>=144,"48dp simulation touch target at 3x")
		for i in range(buttons.size()):
			for j in range(i+1,buttons.size()):
				check(not buttons[i].get_global_rect().intersects(buttons[j].get_global_rect()),"No HUD overlap")
		var point := center(scene,0)
		touch(viewport,point,true)
		touch(viewport,point,false)
		check(scene.demo.plots[0].state=="empty","Immediate touch harvest")
		check(scene.world.effects.size()==1 and scene.world.effects[0].action=="harvest","Authored harvest animation starts immediately")
		check(scene.world.frame_at(scene.world.definition.harvest_durations,0.04)==0,"Harvest first drawing")
		check(scene.world.frame_at(scene.world.definition.harvest_durations,0.18)==1,"Harvest second drawing")
		check(scene.world.frame_at(scene.world.definition.harvest_durations,0.36)==2,"Harvest final drawing")
		touch(viewport,point,true)
		touch(viewport,point,false)
		check(scene.demo.plots[0].state=="needs_water","Plant while harvest FX still running")
		scene.choose("water")
		touch(viewport,point,true)
		touch(viewport,point,false)
		check(scene.demo.plots[0].state=="growing","Direct water via viewport")
		scene.demo.tick(10)
		check(scene.demo.plots[0].state=="mature","Simulated growth only")
		scene.demo.reset()
		scene.demo.plots[1].state = "mature"
		scene.choose("seed")
		touch(viewport,point,true)
		var drag := InputEventScreenDrag.new()
		drag.position = center(scene,1)
		viewport.push_input(drag,true)
		drag.position = point
		viewport.push_input(drag,true)
		touch(viewport,point,false)
		check(scene.demo.harvest_count==2 and scene.demo.plots[0].state=="empty","Fast drag deduplicates and never replants on return")
		scene.demo.reset()
		touch(viewport,point,true,0)
		touch(viewport,center(scene,1),true,1)
		drag.index = 1
		drag.position = center(scene,1)+Vector2(80,0)
		viewport.push_input(drag,true)
		touch(viewport,drag.position,false,1)
		touch(viewport,point,false,0)
		check(scene.demo.action_count==0,"Pinch performs no crop actions")
		scene.frame_camera()
		scene.choose("camera")
		var before: Vector2 = scene.camera
		scene.gesture.press(point)
		scene.gesture.move(point+Vector2(60,0))
		scene.gesture.release(point+Vector2(60,0))
		check(scene.demo.action_count==0 and scene.camera!=before,"Independent camera tool")
		scene.frame_camera()
		scene.choose("seed")
		for down in [true,false]:
			var mouse := InputEventMouseButton.new()
			mouse.position = point
			mouse.button_index = MOUSE_BUTTON_LEFT
			mouse.pressed = down
			viewport.push_input(mouse,true)
		check(scene.demo.harvest_count==1,"Real viewport mouse routing")
		for i in range(80):
			scene.demo.tool = "seed"
			scene.demo.act(0)
			scene.demo.tool = "water"
			scene.demo.act(0)
			scene.demo.tick(10)
			scene.demo.act(0)
		check(scene.world.effects.size()<=16,"Rapid interactions have bounded nonblocking FX")
		scene.open_studio()
		await process_frame
		check(scene.hit_at(point)==-1,"Modal blocks map actions")
		for button in controls(scene.panel):
			check(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(button.get_global_rect()),"Studio controls fit viewport")
			if scene.portrait:
				check(button.size.y>=144,"Studio touch size")
		var prior: bool = scene.world.motion
		scene.toggle_motion()
		check(scene.world.motion!=prior,"Reduced ambient motion")
		viewport.queue_free()
		await process_frame
	print("Independent Cozy pilot checks: %d; failures: %d"%[checks,failures])
	quit(0 if failures==0 else 1)
