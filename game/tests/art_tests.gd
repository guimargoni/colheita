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

func buttons(node: Node) -> Array[Button]:
	var result: Array[Button] = []
	for child in node.get_children():
		if child is Button:
			result.append(child)
		result.append_array(buttons(child))
	return result

func check_layout(node: Node, viewport_size: Vector2, mobile: bool) -> void:
	var controls := buttons(node)
	for button in controls:
		var area := button.get_global_rect()
		check(area.position.x>=0 and area.position.y>=0 and area.end.x<=viewport_size.x+1 and area.end.y<=viewport_size.y+1,"Button fits viewport: "+button.text)
		if mobile:
			check(button.size.x>=132 and button.size.y>=132,"Mobile logical target: "+button.text)
	for i in range(controls.size()):
		for j in range(i+1,controls.size()):
			check(not controls[i].get_global_rect().intersects(controls[j].get_global_rect()),"Controls do not overlap: "+controls[i].text+" / "+controls[j].text)

func touch(viewport: SubViewport, point: Vector2, down: bool, index: int = 0) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.pressed = down
	event.index = index
	viewport.push_input(event,true)

func run() -> void:
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920),Vector2i(720,1280)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var scene = load("res://scenes/art/art_sample.tscn").instantiate()
		viewport.add_child(scene)
		await process_frame
		scene.set_process(false)
		check(scene.demo.plots.size()==4,"Exactly four plots, no hidden simulation")
		check(scene.demo.config.seeds.size()==2,"Exactly two ordinary crops")
		check(not scene.sound.sfx_enabled and not scene.sound.music_enabled,"No placeholder audio silently presented as final")
		check(scene.review_audio.cues.is_empty() and scene.review_audio.loops.is_empty(),"Absent final audio slots fail silently")
		check_layout(scene.ui,Vector2(resolution),scene.portrait)
		check(scene.frame.size.y/scene.logical_size.y>0.72,"At least 72% vertical map space")
		var centers: Array[Vector2] = []
		for id in range(4):
			var point: Vector2 = scene.world.to_global(scene.world.project(scene.ArtGarden.POSITIONS[id])-Vector2(0,48))
			centers.append(point)
			check(scene.hit_at(point)==id,"Visual plot center maps to correct ID")
		# Real viewport dispatch, including GUI routing and emulated touch paths.
		touch(viewport,centers[0],true)
		touch(viewport,centers[0],false)
		check(scene.demo.plots[0].state=="empty","Touch harvest")
		touch(viewport,centers[0],true)
		touch(viewport,centers[0],false)
		check(scene.demo.plots[0].state=="needs_water","Touch plant")
		scene.choose_tool("water")
		touch(viewport,centers[0],true)
		touch(viewport,centers[0],false)
		check(scene.demo.plots[0].state=="growing","Touch water")
		scene.demo.tick(10)
		check(scene.demo.plots[0].state=="mature","Visual maturity state")
		scene.reset_sample()
		scene.demo.tool = "seed"
		touch(viewport,centers[0],true)
		var drag := InputEventScreenDrag.new()
		drag.position = centers[1]
		viewport.push_input(drag,true)
		drag.position = centers[0]
		viewport.push_input(drag,true)
		touch(viewport,centers[0],false)
		check(scene.demo.harvest_count==2,"Drag harvests both once, no replant on return")
		scene.reset_sample()
		touch(viewport,centers[0],true,0)
		touch(viewport,centers[1],true,1)
		var zoom_before: float = scene.zoom_factor
		drag.index = 1
		drag.position = centers[1]+Vector2(70,0)
		viewport.push_input(drag,true)
		touch(viewport,centers[1]+Vector2(70,0),false,1)
		touch(viewport,centers[0],false,0)
		check(scene.demo.action_count==0,"Pinch over plants performs no actions")
		check(not is_equal_approx(zoom_before,scene.zoom_factor),"Pinch zoom reaches camera")
		scene.frame_camera()
		scene.choose_tool("camera")
		scene.gesture.press(centers[0])
		scene.gesture.move(centers[0]+Vector2(50,20))
		scene.gesture.release(centers[0]+Vector2(50,20))
		check(scene.demo.action_count==0 and scene.pan.length()>0,"Camera tool pans without crop mutations")
		var key := InputEventKey.new()
		key.pressed = true
		key.keycode = KEY_DOWN
		scene._shortcut_input(key)
		check(scene.keyboard_plot==2,"Keyboard follows two-column art sample")
		key.keycode = KEY_RIGHT
		scene._shortcut_input(key)
		check(scene.keyboard_plot==3,"Keyboard reaches final plot")
		scene._shortcut_input(key)
		check(scene.keyboard_plot==3 and scene.demo.action_count==0,"Keyboard bounds never act on hidden plots")
		scene.frame_camera()
		scene.choose_tool("seed")
		for pressed in [true,false]:
			var mouse := InputEventMouseButton.new()
			mouse.button_index = MOUSE_BUTTON_LEFT
			mouse.position = centers[0]
			mouse.pressed = pressed
			viewport.push_input(mouse,true)
		check(scene.demo.harvest_count==1,"Mouse through viewport")
		for i in range(100):
			scene.demo.tool = "seed"
			scene.demo.act(0)
			scene.demo.tool = "water"
			scene.demo.act(0)
			scene.demo.tick(10)
			scene.demo.act(0)
		check(scene.garden.effects.size()<=32,"Rapid action effects bounded, no locks")
		var before_transform: Transform2D = scene.world.global_transform
		scene.set_before(true)
		check(scene.world.global_transform==before_transform,"Comparison preserves camera")
		scene.set_before(false)
		scene.toggle_halloween()
		check(scene.garden.halloween and scene.demo.plots[3].state=="mature","Seasonal concept toggles without economy")
		for title in ["Configurações","Loja","Inventário","Amigos"]:
			scene.open_panel(title)
			await process_frame
			check_layout(scene.panel,Vector2(resolution),scene.portrait)
			check(scene.hit_at(centers[0])==-1,"Modal prevents accidental map actions")
			scene.close_panel()
		scene.show_kit()
		await process_frame
		check_layout(scene.panel,Vector2(resolution),scene.portrait)
		var disabled_count := 0
		for button in buttons(scene.panel):
			if button.disabled:
				disabled_count += 1
		check(disabled_count==1,"Kit includes actual disabled state")
		viewport.queue_free()
		await process_frame
	await create_timer(0.3).timeout
	print("G0.5 checks: %d; failures: %d" % [checks,failures])
	quit(0 if failures==0 else 1)
