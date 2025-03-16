shader_type canvas_item;
render_mode unshaded;

uniform float radius = 0.35;
uniform float feather = 0.15;

void fragment() {
	float dist = distance(vec2(0.5, 0.5), UV.xy); // Get distance to center
	float x = smoothstep(radius, radius + feather, dist); // 0 if x < radius; lerp to 1; 1 > radius + feather
	
	COLOR = mix(COLOR, vec4(0.0), x);
}
