shader_type spatial;

uniform vec3 Player = vec3(300,300,0);
uniform float Radius = 200.0;
uniform float Blur = 0.9;

void fragment() 
{
	vec4 player_world = vec4(Player, 1.);
	vec4 player_screen = player_world * VIEW_MATRIX;
    float dist = distance( player_screen.xy, FRAGCOORD.xy );
    // compute signal based on circle radius
    float signal = 1.0 - smoothstep( Radius, Radius*(1.0-Blur), dist );
    ALBEDO = vec3(0.7);
	// now modify the alpha by the circle
    ALPHA *= signal;
}

//void fragment()
//{
	//
	//vec4 view_position = VIEW_MATRIX * world_position;
	//vec4 clip_position = PROJECTION_MATRIX * view_position;
	//vec2 normalized_device_coordinate_position = (clip_position.xy / clip_position.w); // Range -1.0 - 1.0, can covert to screen space by adding *0.5+0.5	
//}
