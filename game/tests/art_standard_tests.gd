extends SceneTree

var checks: int = 0
var failures: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var model = load("res://scripts/visual/art_lab_model.gd").new()
	check(model.standard.final_plot_count==null and model.standard.unlock_costs==null and model.standard.initial_plot_count==null,"Product counts and unlock costs remain undecided")
	for asset in model.standard.assets:
		var canvas := Vector2(asset.logical_canvas[0],asset.logical_canvas[1])
		var bounds := Rect2(asset.visual_bounds[0],asset.visual_bounds[1],asset.visual_bounds[2],asset.visual_bounds[3])
		check(Rect2(Vector2.ZERO,canvas).encloses(bounds),"Visual envelope inside source canvas: "+asset.id)
		check(Rect2(Vector2.ZERO,canvas).has_point(Vector2(asset.pivot[0],asset.pivot[1])),"Pivot inside canvas")
		check(not asset.release_approved and not asset.animation.alignment_verified,"No invented production approval")
		check(asset.animation.frames.is_empty(),"Production frames honestly absent")
		check(asset.skin_contract=="cozy.iso.v1","Shared skin geometry version")
		check(not asset.directions.is_empty() and not asset.snap_points.is_empty(),"Directions and connections required")
		for scale in asset.allowed_presentation_scales:
			check(scale>0 and scale==int(scale),"Only integer presentation scales")
		for socket in asset.snap_points:
			var point := Vector2(asset.pivot[0]+socket.position[0],asset.pivot[1]+socket.position[1])
			check(point.x>=0 and point.y>=0 and point.x<=canvas.x and point.y<=canvas.y,"Socket fits declared canvas")
	for p in [Vector2(-17,-3),Vector2(0,0),Vector2(64,90),Vector2(0.5,0.25)]:
		check(model.unproject(model.project(p)).distance_to(p)<0.00001,"32x16 projection invertible including negative cells")
	check(model.project(Vector2(2,0))==Vector2(32,16),"East plot adjacency")
	check(model.project(Vector2(0,2))==Vector2(-32,16),"South plot adjacency")
	var common := {}
	for key in ["compact","dense","avenues"]:
		var early = model.fixture(key,false)
		var later = model.fixture(key,true)
		check(early.size()==later.size(),"Visual access phase cannot change geometry")
		var ids := {}
		var has_locked := false
		for i in range(early.size()):
			var plot: Dictionary = early[i]
			check(not ids.has(plot.id),"Unique coordinate-derived IDs")
			ids[plot.id] = true
			check(plot.id==later[i].id and plot.cell==later[i].cell,"Expansion phase preserves IDs and positions")
			check(model.pick(model.project(plot.cell),early)==i,"Picking every plot at full expansion extent")
			check(model.bounds(early).has_point(model.project(plot.cell)),"Camera bounds include all centers")
			if common.has(plot.id):
				check(common[plot.id]==plot.cell,"Wider fixture never renumbers plots")
			common[plot.id] = plot.cell
			has_locked = has_locked or plot.state=="locked"
		check(has_locked,"Every early fixture includes expansion space")
		check(model.pick(Vector2(-5000,-5000),early)==-1,"Empty region not a plot")
	var compact = model.fixture("compact")
	check(model.pick(model.project(Vector2(1,0)),compact)==1,"Shared boundary has exactly one owner")
	check(model.fixture("avenues").size()==100,"QA fixture reserves paths; not final capacity")
	for resolution in [Vector2i(1920,1080),Vector2i(1080,1920)]:
		var viewport := SubViewport.new()
		viewport.size = resolution
		root.add_child(viewport)
		var lab = load("res://scenes/art/art_lab.tscn").instantiate()
		viewport.add_child(lab)
		await process_frame
		check(lab.zoom==int(lab.container.scale.x),"Integer display scale")
		check(lab.world.position==lab.world.position.round(),"Camera snapped to source pixel")
		for child in lab.hud.get_children():
			if child is Button:
				check(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(child.get_global_rect()),"Lab control fits viewport")
				if resolution.y>resolution.x:
					check(child.size.y>=132,"Portrait control target")
		lab.select_fixture("avenues")
		var stable = lab.world.plots.duplicate(true)
		lab.toggle_palette()
		check(lab.world.plots==stable,"Palette cannot mutate cells/access/cultivation")
		lab.toggle_expanded()
		check(lab.world.plots.size()==stable.size(),"Phase is inspection only")
		lab.frame_all()
		var area: Rect2 = lab.area
		for plot in lab.world.plots:
			var screen: Vector2 = lab.container.position+(lab.world.position+model.project(plot.cell))*lab.zoom
			check(area.has_point(screen),"Expanded overview includes every plot center")
		var anchor: Vector2 = area.get_center()
		var before: Vector2 = lab.map_point(anchor)
		lab.change_zoom(1,anchor)
		check(lab.map_point(anchor).distance_to(before)<=1.5,"Anchored quantized zoom within pixel rounding tolerance")
		check(lab.world.frame_at([1.1,0.12,0.55,1.45],1.11)==1,"Individual frame duration respected")
		check(lab.world.frame_at([1.1,0.12,0.55,1.45],3.22)==0,"Timing loop returns to start")
		viewport.queue_free()
		await process_frame
	print("G0.5-R structural/lab checks: %d; failures: %d (not artistic approval)"%[checks,failures])
	quit(0 if failures==0 else 1)
