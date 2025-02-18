// Adapted from https://www.youtube.com/watch?v=krpd7sHrTXw

shader_type spatial;

uniform float sphere_radius = 5.5;
uniform vec4 _color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensity = 0.0;

global uniform vec3 Player;

varying vec3 world_vertex;

void vertex()
{
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{
	ALBEDO = _color.rgb;

	float min_dist = min(length(Player - world_vertex), sphere_radius);
	ALPHA = 1.0 - (intensity * clamp(sphere_radius - min_dist, 0.0, 1.0));
}
