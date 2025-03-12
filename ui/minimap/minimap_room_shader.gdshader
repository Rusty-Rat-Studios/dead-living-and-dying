shader_type spatial;
render_mode unshaded;

uniform vec4 fg_albedo : source_color;
uniform vec4 bg_albedo : source_color;
uniform float width = 0.2;

void vertex() {
	
}

void fragment() {
	vec2 base_uv = UV;

	if(UV.x <= width){
		ALBEDO = fg_albedo.rgb;
	}
	else if(UV.x >= 1.0 - width){
		ALBEDO = fg_albedo.rgb;
	}
	else if(UV.y <= width){
		ALBEDO = fg_albedo.rgb;
	}
	else if(UV.y >= 1.0 - width){
		ALBEDO = fg_albedo.rgb;
	}
	else{
		ALBEDO = bg_albedo.rgb;
	}
	
}
