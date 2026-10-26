extends "res://scripts/ui/pilot_ui.gd"
## Reusable native components; original code-drawn UI, no third-party icon/font.
var hybrid: bool = false
var intensity: float = 0.65
var reduced: bool = false

func surface(color: Color, radius: int = 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius if hybrid else 5)
	s.border_color = Color("dacba5")
	s.set_border_width_all(1 if hybrid else 2)
	s.shadow_color = Color(0.08,0.18,0.16,0.17)
	s.shadow_size = 12 if hybrid else 4
	s.shadow_offset = Vector2(0,5)
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		s.set_content_margin(side,22)
	return s

func button(text: String, area: Rect2, action: Callable, primary: bool = false, parent: Control = null) -> Button:
	var b := Button.new()
	b.text = tr(text)
	b.tooltip_text = tr(text)
	b.position = area.position
	b.size = area.size
	b.add_theme_font_size_override("font_size",28 if mobile else 23)
	for state in ["normal","hover","pressed","disabled"]:
		var color := Color("28574e") if primary else Color("fff8e8")
		if state=="hover": color = color.lightened(0.08)
		if state=="pressed": color = Color("54816b") if primary else Color("e3eacb")
		if state=="disabled": color = Color("d8d9c9")
		b.add_theme_stylebox_override(state,surface(color))
	for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		b.add_theme_color_override(state,PAPER if primary else INK)
	b.add_theme_color_override("font_disabled_color",Color("66736a"))
	var focus := surface(Color.TRANSPARENT)
	focus.border_color = Color("b57924")
	focus.set_border_width_all(3)
	b.add_theme_stylebox_override("focus",focus)
	(parent if parent!=null else root).add_child(b)
	if text in ["Semear","Cuidados","Câmera","Inventário","Loja","Ajustes","Foco"]:
		var icon := preload("res://scripts/ui/g1v/line_icon.gd").new()
		icon.kind = text
		icon.ink = PAPER if primary else INK
		icon.position = Vector2(15,area.size.y/2-12)
		icon.size = Vector2(24,24)
		b.add_child(icon)
		b.add_theme_constant_override("outline_size",0)
		b.resized.connect(func() -> void: icon.position.y = b.size.y/2-12)
	b.pressed.connect(action)
	b.button_down.connect(func() -> void:
		var owner_scene: Node = root.get_parent()
		if "audio" in owner_scene and is_instance_valid(owner_scene.audio): owner_scene.audio.play("button")
	)
	b.button_down.connect(func() -> void: animate_button(b,0.965))
	b.button_up.connect(func() -> void: animate_button(b,1.0))
	b.mouse_entered.connect(func() -> void: animate_button(b,1.015))
	b.mouse_exited.connect(func() -> void: animate_button(b,1.0))
	return b

func animate_button(b: Button, target: float) -> void:
	if reduced or intensity<=0 or not is_instance_valid(b): return
	b.pivot_offset = b.size/2
	if b.has_meta("feel_tween"):
		var old: Tween = b.get_meta("feel_tween")
		if is_instance_valid(old): old.kill()
	var t := b.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	b.set_meta("feel_tween",t)
	t.tween_property(b,"scale",Vector2.ONE*(1+(target-1)*intensity),0.11)
