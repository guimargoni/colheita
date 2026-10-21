extends SceneTree
## G0.3 projection, scene, input and layout regression checks; no gameplay simulation.

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func mouse_button(point: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	return event


func touch(point: Vector2, index: int, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.index = index
	event.pressed = pressed
	return event


func all_buttons(node: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		buttons.append_array(all_buttons(child))
	return buttons


func _run() -> void:
	for resolution: Vector2i in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		for proposal: String in ["a","b"]:
			var viewport := SubViewport.new()
			viewport.size = resolution
			root.add_child(viewport)
			var study: Control = load("res://scenes/comparison/proposal_"+proposal+".tscn").instantiate()
			viewport.add_child(study)
			await process_frame
			check(study.direction == proposal.to_upper(), "Correct proposal scene")
			check(study.portrait == (resolution.y>resolution.x), "Responsive orientation")
			check(study.world_layer.clip_contents,"World camera clips independently of HUD")
			check(study.world.fixture.plot_rows*study.world.fixture.plot_columns==16, "Exactly sixteen plots")
			for p: Vector2 in [Vector2(-1,2),Vector2(4.5,6),Vector2(9,0)]:
				check(study.world.unproject(study.world.project(p)).distance_to(p)<0.001,"Projection inverse")
			for row in range(4):
				for col in range(4):
					var p := Vector2(2.7+col*1.06+0.44,3+row*1.06+0.44)
					check(study.world.plot_at(p)==row*4+col,"Plot hit mapping")
			check(study.world.plot_at(Vector2(9,4))==-1,"Expansion is not a plot")
			var hud_buttons: Array[Button] = all_buttons(study.ui)
			for button in hud_buttons:
				check(button.position.x>=0 and button.position.y>=0,"Button on screen: "+button.text)
				check(button.position.x+button.size.x<=study.logical_size.x+1,"Button fits width: "+button.text)
				check(button.position.y+button.size.y<=study.logical_size.y+1,"Button fits height: "+button.text)
				if study.portrait:
					check(button.size.x>=132 and button.size.y>=132,"132px mobile touch target: "+button.text)
			for i in range(hud_buttons.size()):
				for j in range(i+1,hud_buttons.size()):
					check(not hud_buttons[i].get_global_rect().intersects(hud_buttons[j].get_global_rect()),"HUD controls do not overlap")
			study.focus_plots()
			var screen: Vector2 = study.world.to_global(study.world.project(Vector2(3.14,3.44)))
			study._select_at(screen)
			check(study.world.selected_plot==0,"Projected scene selection")
			study.world.selected_plot = -1
			viewport.push_input(mouse_button(screen,true),true)
			viewport.push_input(mouse_button(screen,false),true)
			check(study.world.selected_plot==0,"Mouse reaches map through actual viewport GUI routing")
			study.reset_camera()
			var anchor: Vector2 = study.frame.get_center()*study.ui_scale
			study._zoom(1.2,anchor)
			check(is_equal_approx(study.zoom_factor,1.2),"Anchored zoom")
			study._unhandled_input(mouse_button(anchor,true))
			var motion := InputEventMouseMotion.new()
			motion.position = anchor+Vector2(60,20)
			study._unhandled_input(motion)
			check(study.pan.length()>0,"Mouse drag pans camera")
			study._unhandled_input(mouse_button(Vector2.ZERO,false))
			check(not study.dragging,"Mouse release outside farm ends drag")
			study.reset_camera()
			study._unhandled_input(touch(anchor,0,true))
			var drag := InputEventScreenDrag.new()
			drag.index = 0
			drag.position = anchor+Vector2(30,20)
			study._unhandled_input(drag)
			check(study.pan.length()>0,"Touch pan")
			study._unhandled_input(touch(drag.position,0,false))
			study._unhandled_input(touch(anchor-Vector2(80,0),0,true))
			study._unhandled_input(touch(anchor+Vector2(80,0),1,true))
			drag.index = 1
			drag.position = anchor+Vector2(140,0)
			study._unhandled_input(drag)
			check(study.zoom_factor>1,"Two-finger pinch zoom")
			study._unhandled_input(touch(anchor,0,false))
			study._unhandled_input(touch(anchor,1,false))
			check(study.touches.is_empty(),"Touch state clears")
			for title: String in ["Loja","Amigos","Inventário"]:
				study._open_preview(title)
				check(study.panel!=null,"Preview panel opens: "+title)
				study._close_preview()
			study.toggle_motion()
			check(not study.world.animation_enabled,"Reduced motion pauses ambient animation")
			study.set_direction("menu")
			check(not study.world.visible,"Menu hides world")
			var menu_buttons: Array[Button] = all_buttons(study.ui)
			check(menu_buttons.size()==2,"Two menu proposals")
			menu_buttons[1].pressed.emit()
			check(study.direction=="B","Menu navigates to B")
			study.set_direction("A")
			check(study.world.isometric,"Menu/switch can restore A")
			viewport.queue_free()
			await process_frame
	print("G0.3 tests: ", "PASS" if failures==0 else "FAIL", " (",checks," checks)")
	quit(0 if failures==0 else 1)
