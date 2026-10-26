extends Control
## Small original line icons for native UI, not replacement world art.
var kind: String = ""
var ink := Color("244f47")
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	var w: float = 2
	match kind:
		"Semear":
			draw_polyline(PackedVector2Array([Vector2(2,21),Vector2(9,13),Vector2(18,7)]),ink,w,true)
			draw_arc(Vector2(11,10),10,0.5,3.8,16,ink,w,true)
			draw_line(Vector2(2,7),Vector2(18,2),ink,w,true)
		"Cuidados":
			draw_polyline(PackedVector2Array([Vector2(11,1),Vector2(3,13),Vector2(3,18),Vector2(8,23),Vector2(15,23),Vector2(20,18),Vector2(20,13),Vector2(11,1)]),ink,w,true)
		"Inventário":
			draw_rect(Rect2(2,6,20,17),ink,false,w)
			draw_line(Vector2(2,12),Vector2(22,12),ink,w,true)
			draw_line(Vector2(8,3),Vector2(16,3),ink,w,true)
		"Loja":
			draw_polyline(PackedVector2Array([Vector2(3,9),Vector2(5,23),Vector2(21,23),Vector2(23,9),Vector2(3,9)]),ink,w,true)
			draw_arc(Vector2(13,9),6,PI,TAU,16,ink,w,true)
		"Ajustes":
			for i in range(3):
				draw_line(Vector2(2,5+i*7),Vector2(23,5+i*7),ink,w,true)
				draw_circle(Vector2(8 if i%2==0 else 17,5+i*7),3,ink)
		_:
			draw_arc(Vector2(12,12),8,0,TAU,24,ink,w,true)
			draw_line(Vector2(12,0),Vector2(12,24),ink,w,true)
			draw_line(Vector2(0,12),Vector2(24,12),ink,w,true)
