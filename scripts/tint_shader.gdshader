shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0,1.0,0.0,1.0);
uniform float blend_amount : hint_range(0.0,1.0) = 1.0;
uniform sampler2D screen_texture : hint_screen_texture,filter_nearest;

void fragment() {
	vec4 screen_color = texture(screen_texture,SCREEN_UV);
	vec3 tinted = screen_color.rgb * tint_color.rgb;
	COLOR.rgb = mix(screen_color.rgb, tinted, blend_amount);
	COLOR.a = screen_color.a;
}
