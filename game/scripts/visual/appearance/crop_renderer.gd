extends RefCounted
func draw(host: Node2D,id: int) -> void:
	var at: Vector2 = host.plot_center(id)
	var p: Dictionary = host.demo.plots[id]
	host.paint_asset("plot."+str(id),"crops.soil",at,Color(0.60,0.67,0.55) if p.state=="locked" else Color.WHITE.lightened(0.12) if id==host.hover_id else Color.WHITE)
	if p.state=="locked":
		host.draw_string(ThemeDB.fallback_font,at+Vector2(-10,3),p.short_label+"+",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("fff6de"))
		return
	if p.crop_id.is_empty(): return
	var key: String = "seed" if p.stage==0 and p.state!="mature" else host.crop_key(p.crop_id,p.state)
	var sway: float = sin(host.clock*1.6+id*1.87)*0.025*host.intensity if host.motion else 0.0
	var spring: float = host.springs.get(id,0.0)
	sway += sin((0.4-spring)*23)*spring*0.05*host.intensity if host.motion and spring>0 else 0.0
	var tint := Color.WHITE
	if p.state=="mature" and host.motion:
		tint = tint.lerp(Color(1.1,1.06,0.97),maxf(0,sin(host.clock+id))*0.35*host.intensity)
	host.paint_asset(p.crop_id,"culture."+p.crop_id,at,tint,sway,"seed" if key=="seed" else p.state)
	if p.care.needs_water:
		host.draw_circle(at+Vector2(21,-12),3,Color("60c9e3"))
	if p.care.weeds:
		host.draw_string(ThemeDB.fallback_font,at+Vector2(-28,-8),"Ervas",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("5b782e"))
	if p.care.pests:
		host.draw_string(ThemeDB.fallback_font,at+Vector2(12,-8),"Praga",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("a5574e"))

	if p.state=="mature":
		var badge: Dictionary = host.appearance.resolve("status.mature","ui.star")
		badge.size = [9,9]; badge.pivot = [4.5,4.5]
		host.painted(host.appearance.texture(badge),badge,at+Vector2(21,-24))
