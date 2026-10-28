extends "res://scripts/ui/g1v/living_kit.gd"
## Native game components; illustrated icons, accessible labels and keyboard focus.
const ICONS = preload("res://assets/art/visual_v2/icons_v2.png")
var accent: Color = Color("397b69")
var paper: Color = Color("fff4dc")
const KEYS = ["coin","star","Loja","Inventário","Semear","Cuidados","Decoração","Amigos","Ajustes","Câmera","Fazenda","Aparência","egg","honey","milk","bouquet"]
var appearance = preload("res://scripts/visual/appearance/resolver.gd").new()
func item_icon(key: String) -> Texture2D:
	return appearance.preview("ui."+(key if key in KEYS else "Fazenda"),"ui."+key)
func surface(color: Color,radius: int = 16) -> StyleBoxFlat:
	var style := super.surface(color,radius)
	style.set_corner_radius_all(18)
	style.border_color = Color("bba16b")
	style.set_border_width_all(2)
	style.border_width_bottom = 5
	style.shadow_size = 7
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: style.set_content_margin(side,16)
	return style
func button(text: String,area: Rect2,action: Callable,primary: bool = false,parent: Control = null) -> Button:
	var b := Button.new(); b.text = tr(text); b.tooltip_text = tr(text)
	b.position = area.position; b.size = area.size
	b.add_theme_font_size_override("font_size",24 if mobile else 22)
	for state in ["normal","hover","pressed","disabled"]:
		var color: Color = accent if primary else paper
		if state=="hover": color = color.lightened(0.08)
		if state=="pressed": color = color.darkened(0.08)
		if state=="disabled": color = Color("d7d5c8")
		b.add_theme_stylebox_override(state,surface(color))
	for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		b.add_theme_color_override(state,PAPER if primary else INK)
	b.add_theme_color_override("font_disabled_color",Color("66736a"))
	var focus := surface(Color.TRANSPARENT); focus.border_color = Color("c08625"); focus.set_border_width_all(3)
	b.add_theme_stylebox_override("focus",focus)
	(parent if parent!=null else root).add_child(b)
	b.pressed.connect(action)
	b.button_down.connect(func() -> void:
		var owner_scene: Node = root.get_parent()
		if "audio" in owner_scene and is_instance_valid(owner_scene.audio): owner_scene.audio.play("button")
		animate_button(b,0.965))
	b.button_up.connect(func() -> void: animate_button(b,1.0))
	b.mouse_entered.connect(func() -> void: animate_button(b,1.015))
	b.mouse_exited.connect(func() -> void: animate_button(b,1.0))
	return b
func dock(text: String,area: Rect2,action: Callable,selected: bool = false) -> Button:
	var b := button("",area,action,selected)
	b.tooltip_text = text; b.accessibility_name = text
	b.icon = item_icon(text); b.expand_icon = true; b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_theme_constant_override("icon_max_width",int(area.size.x*0.65))
	var caption := Label.new(); caption.text = text
	caption.add_theme_font_size_override("font_size",18 if mobile else 16)
	caption.add_theme_color_override("font_color",PAPER if selected else INK)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.position = Vector2(0,area.size.y-25); caption.size = Vector2(area.size.x,24)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE; b.add_child(caption)
	return b
func illustration(parent: Control,texture: Texture2D,side: int = 92) -> TextureRect:
	var image := TextureRect.new(); image.texture = texture
	image.custom_minimum_size = Vector2(side,side); image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image); return image
