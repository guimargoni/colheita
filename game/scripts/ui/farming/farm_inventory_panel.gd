extends RefCounted

static func create(kit: RefCounted, logical: Vector2, service: RefCounted, select: Callable, close: Callable) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = Vector2((logical.x-948)/2,(logical.y-898)/2)
	panel.size = Vector2(948,898)
	var skin: StyleBoxTexture = kit.box(Rect2(1080,64,435,418))
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		skin.set_content_margin(side,64)
	panel.add_theme_stylebox_override("panel",skin)
	kit.root.add_child(panel)
	var content := Control.new()
	content.custom_minimum_size = Vector2(820,770)
	panel.add_child(content)
	kit.label("Sementes e colheita · local DEV",Rect2(0,0,820,66),34,kit.INK,content)
	for i in range(service.catalog.ids.size()):
		var id: String = service.catalog.ids[i]
		var crop: Dictionary = service.catalog.entries[id]
		var note := " · arte provisória" if crop.art.status=="PLACEHOLDER" else ""
		var text := "%s%s\n%d sementes · %d produtos · %d s de cultivo"%[TranslationServer.translate(crop.name),note,int(service.state.get("inventory",{}).get("seeds",{}).get(id,0)),int(service.state.get("inventory",{}).get("products",{}).get(id,0)),int(crop.growth_seconds)]
		kit.button(text,Rect2(0,80+i*150,820,144),select.bind(i),false,content)
	kit.label("Toque numa cultura para selecionar a semente.\nSem loja, venda, moedas ou XP neste gate.",Rect2(0,540,820,64),25,kit.INK,content)
	kit.button("Voltar à fazenda",Rect2(0,630,820,144),close,true,content)
	return panel
