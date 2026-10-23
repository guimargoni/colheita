extends RefCounted
## Small native Control kit with original raster skin, independent of G0.5 HUD.

const SKIN = preload("res://assets/art/g05r_pilot/ui_v1.png")
const INK := Color("203d4a")
const PAPER := Color("fff2d5")
var root: Control
var mobile: bool = false

func box(region: Rect2, tint: Color = Color.WHITE) -> StyleBoxTexture:
	var result := StyleBoxTexture.new()
	result.texture = SKIN
	result.region_rect = region
	result.modulate_color = tint
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		result.set_texture_margin(side,36)
		result.set_content_margin(side,16)
	return result

func label(text: String, area: Rect2, size: int, color: Color = INK, parent: Control = null) -> Label:
	var item := Label.new()
	item.text = tr(text)
	item.position = area.position
	item.size = area.size
	item.add_theme_font_size_override("font_size",size)
	item.add_theme_color_override("font_color",color)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent!=null else root).add_child(item)
	return item

func icon(region: Rect2, area: Rect2, parent: Control = null) -> void:
	var item := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = SKIN
	atlas.region = region
	item.texture = atlas
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.position = area.position
	item.size = area.size
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent!=null else root).add_child(item)

func button(text: String, area: Rect2, action: Callable, primary: bool = false, parent: Control = null) -> Button:
	var item := Button.new()
	item.text = tr(text)
	item.tooltip_text = tr(text)
	item.position = area.position
	item.size = area.size
	var region := Rect2(48,190,470,180) if primary else Rect2(555,190,470,180)
	for state in ["normal","hover","pressed","disabled"]:
		var tint: Color = {"normal":Color.WHITE,"hover":Color(1.08,1.07,1),"pressed":Color("b5c6bb"),"disabled":Color("8c9794")}[state]
		var skin := box(region,tint)
		# Full authored button image; raw source margins cannot become 36px UI borders.
		for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
			skin.set_texture_margin(side,0)
		item.add_theme_stylebox_override(state,skin)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("f2c34e")
	focus.set_border_width_all(3)
	item.add_theme_stylebox_override("focus",focus)
	item.add_theme_color_override("font_color",PAPER if primary else INK)
	item.add_theme_color_override("font_hover_color",PAPER if primary else INK)
	item.add_theme_font_size_override("font_size",30 if mobile else 24)
	item.pressed.connect(action)
	(parent if parent!=null else root).add_child(item)
	return item
