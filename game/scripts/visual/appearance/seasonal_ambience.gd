extends Node2D
## Native light + AnimationPlayer; effects only, never authority or loot.
var glow: PointLight2D
var animator: AnimationPlayer
func _ready() -> void:
	glow = PointLight2D.new(); glow.name = "LanternGlow"
	var texture := GradientTexture2D.new(); texture.width = 128; texture.height = 128
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5,0.5); texture.fill_to = Vector2(1,0.5)
	var gradient := Gradient.new(); gradient.colors = PackedColorArray([Color(1,0.65,0.22,0.5),Color(1,0.4,0.12,0)])
	texture.gradient = gradient; glow.texture = texture
	glow.texture_scale = 0.6; glow.energy = 0.35; glow.position = Vector2(-48,-30); add_child(glow)
	animator = AnimationPlayer.new(); add_child(animator)
	var animation := Animation.new(); animation.length = 3.7; animation.loop_mode = Animation.LOOP_LINEAR
	var track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track,NodePath("LanternGlow:energy"))
	animation.track_insert_key(track,0,0.25); animation.track_insert_key(track,1.8,0.5); animation.track_insert_key(track,3.7,0.25)
	var library := AnimationLibrary.new(); library.add_animation("warmth",animation)
	animator.add_animation_library("",library); animator.play("warmth")
func comfort(enabled: bool,motion: bool,intensity: float) -> void:
	visible = enabled and intensity>0
	if animator==null: return
	animator.speed_scale = 1 if motion else 0
	glow.energy = minf(glow.energy,0.5)*intensity if motion else 0.25*intensity
