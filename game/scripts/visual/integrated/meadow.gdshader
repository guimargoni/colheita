shader_type canvas_item;
uniform float phase = 0.0;
uniform float strength = 0.0;
uniform vec4 seasonal_tint : source_color = vec4(1.0);
void fragment() {
 vec2 uv = UV;
 float water = smoothstep(0.79,0.96,uv.x);
 uv.y += sin(uv.x*57.0+phase*1.1)*0.001*water*strength;
 COLOR = texture(TEXTURE,uv)*seasonal_tint;
}
