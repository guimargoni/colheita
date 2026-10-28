extends "res://scripts/ui/g1v/living_economy_ui.gd"
func crop_card(body: Control, id: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",scene.kit.surface(Color("fffaf0")))
	body.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	panel.add_child(column)
	var row := HBoxContainer.new()
	column.add_child(row)
	var image := TextureRect.new()
	image.texture = scene.world.crop_texture(id,"mature")
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(104,104)
	row.add_child(image)
	var title := Label.new()
	title.text = scene.service.catalog.entries[id].name
	title.add_theme_color_override("font_color",scene.kit.INK)
	title.add_theme_font_size_override("font_size",28)
	row.add_child(title)
	return column

func open_inventory() -> void:
	super.open_inventory()
	if scene.panel==null: return
	var scrolls: Array[Node] = scene.panel.find_children("*","ScrollContainer",true,false)
	if scrolls.is_empty(): return
	var body: VBoxContainer = scrolls[0].get_child(0)
	label(body,"Produção e buquês")
	for id in scene.service.state.features.goods:
		var count: int = int(scene.service.state.features.goods[id])
		var name: String = {"egg":"Ovos","milk":"Leite","honey":"Mel","wool":"Lã","bouquet":"Buquês"}.get(id,id)
		label(body,"%s · %d guardados"%[name,count])
		button(body,"Vender 1 "+name,sell_feature.bind(id),count<1)
func sell_feature(id: String) -> void:
	scene.feature_action("sell_goods",{"kind":id,"quantity":1})
	open_inventory()

func category_filter(parent: Control) -> void:
	super.category_filter(parent)
	var selector: OptionButton = parent.get_child(parent.get_child_count()-1)
	selector.custom_minimum_size.y = 96 if scene.portrait else 56
	for state in ["normal","hover","pressed","disabled"]:
		selector.add_theme_stylebox_override(state,scene.kit.surface(Color("fffaf0")))
	for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		selector.add_theme_color_override(state,scene.kit.INK)
	var popup := selector.get_popup()
	popup.add_theme_stylebox_override("panel",scene.kit.surface(scene.kit.PAPER))
	popup.add_theme_font_size_override("font_size",26)
	popup.add_theme_color_override("font_color",scene.kit.INK)
