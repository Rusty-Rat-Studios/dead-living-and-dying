// Adapted from https://www.youtube.com/watch?v=krpd7sHrTXw

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color = vec4(1,1,1,1);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform vec3 player_offset = vec3(0, 3, 0);
uniform float sphere_radius = 6.5;
instance uniform float intensity = 0.0;

global uniform vec3 Player;

varying vec3 world_vertex;

void vertex()
{
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float min_dist = min(length((Player + player_offset) - world_vertex), sphere_radius);
	ALPHA = 1.0 - (intensity * clamp(sphere_radius - min_dist, 0.0, 1.0));
}
