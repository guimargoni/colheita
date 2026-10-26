shader_type canvas_item;
render_mode unshaded;
uniform bool hybrid = false;
void fragment() {
 vec4 source = texture(TEXTURE, UV);
 if (hybrid) {
  float edge = smoothstep(0.24,0.8,distance(UV,vec2(0.48,0.45)));
  source.rgb *= mix(vec3(1.025,1.012,0.965),vec3(0.91,0.96,0.96),edge*0.28);
 }
 COLOR = source;
}
