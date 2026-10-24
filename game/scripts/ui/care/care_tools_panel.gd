extends RefCounted
const ATLAS = preload("res://assets/art/g12/care_atlas_v1.png")

static func create(kit: RefCounted, logical: Vector2, service: RefCounted, choose: Callable, close: Callable) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = Vector2((logical.x-948)/2,(logical.y-1040)/2)
	panel.size = Vector2(948,1040)
	var skin: StyleBoxTexture = kit.box(Rect2(1080,64,435,418))
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		skin.set_content_margin(side,64)
	panel.add_theme_stylebox_override("panel",skin)
	kit.root.add_child(panel)
	var content := Control.new()
	content.custom_minimum_size = Vector2(820,912)
	panel.add_child(content)
	kit.label("Cuidados · selecione e toque na planta",Rect2(0,0,820,68),32,kit.INK,content)
	var rows := [["Regar","water",""],["Ervas · remover","remove_weeds","weeds"],["Pragas · remover","remove_pests","pests"]]
	for id in service.items:
		var item: Dictionary = service.items[id]
		var count := int(service.state.get("inventory",{}).get("fertilizers",{}).get(id,0))
		rows.append([item.name+" · "+str(count)+( "\nArmar apenas 1 uso" if item.rare else ""),id,item.icon])
	var art: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/farming/g12/art.json"))
	for i in range(rows.size()):
		var x := float(i%2)*426
		var y := 100.0+float(i/2)*164
		var entry: Array = rows[i]
		var button: Button = kit.button(entry[0],Rect2(x,y,394,144),choose.bind(entry[1]),false,content)
		button.add_theme_font_size_override("font_size",25 if kit.mobile else 22)
		if entry[1]=="fertilizer.social":
			button.disabled = true
			button.tooltip_text = TranslationServer.translate("Futuro: fazenda de amigos; indisponível neste gate")
		if not str(entry[2]).is_empty():
			var icon := TextureRect.new()
			var source := AtlasTexture.new()
			source.atlas = ATLAS
			var r: Array = art[entry[2]].rect
			source.region = Rect2(r[0],r[1],r[2],r[3])
			icon.texture = source
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.position = Vector2(12,46)
			icon.size = Vector2(42,50)
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(icon)
	kit.button("Voltar",Rect2(0,754,820,144),close,true,content)
	return panel
