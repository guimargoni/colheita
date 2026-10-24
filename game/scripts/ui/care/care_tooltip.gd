extends PanelContainer
## One contextual card in screen space; never one timer per plot.
var text: Label

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color("fff2d5")
	paper.border_color = Color("203d4a")
	paper.set_border_width_all(2)
	paper.set_corner_radius_all(10)
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		paper.set_content_margin(side,16)
	add_theme_stylebox_override("panel",paper)
	text = Label.new()
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_theme_color_override("font_color",Color("203d4a"))
	add_child(text)

func show_near(anchor: Vector2, map: Rect2, message: String, mobile: bool) -> void:
	text.text = message
	text.add_theme_font_size_override("font_size",28 if mobile else 22)
	size = Vector2(800,190) if mobile else Vector2(570,158)
	position = anchor-Vector2(size.x/2,size.y+18)
	position.x = clampf(position.x,map.position.x+16,map.end.x-size.x-16)
	position.y = clampf(position.y,map.position.y+12,map.end.y-size.y-12)
	visible = true
