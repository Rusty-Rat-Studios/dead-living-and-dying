shader_type spatial;

uniform vec2 CircleCentre = vec2(0,0);
uniform float CircleRadius = 100.0;
uniform float CircleBlur = 0.1;

void fragment() 
{
    // make sure blur is in the expected range (could be done with a hint)
    float circle_blur = clamp( 0.0, 1.0, CircleBlur );
    // compute distance between fragment and circle centre
    float circle_dist = distance( CircleCentre, FRAGCOORD.xy );
    // compute signal based on circle radius
    float circle_signal = 1.0 - smoothstep( CircleRadius, CircleRadius*(1.0-circle_blur), circle_dist );
    ALBEDO = vec3(0.7);
	// now modify the alpha by the circle
    ALPHA *= circle_signal;
}
