shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 0.05) = 0.01;
uniform float distortion_speed : hint_range(0.0, 5.0) = 1.0;
uniform float distortion_frequency : hint_range(1.0, 50.0) = 10.0;

uniform vec4 tint_color : source_color = vec4(0.1, 0.4, 0.5, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.25;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float vignette_strength : hint_range(0.0, 2.0) = 0.8;
uniform float vignette_radius : hint_range(0.0, 1.5) = 0.75;

uniform bool enable_caustics = true;
uniform float caustic_strength : hint_range(0.0, 1.0) = 0.15;
uniform float caustic_scale : hint_range(1.0, 20.0) = 6.0;
uniform float caustic_speed : hint_range(0.0, 5.0) = 0.5;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);

	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x) +
			(c - a) * u.y * (1.0 - u.x) +
			(d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = SCREEN_UV;

	float wave_x = sin(uv.y * distortion_frequency + TIME * distortion_speed) * distortion_strength;
	float wave_y = cos(uv.x * distortion_frequency + TIME * distortion_speed * 0.8) * distortion_strength;

	vec2 distorted_uv = uv + vec2(wave_x, wave_y);

	vec4 screen_color = texture(SCREEN_TEXTURE, distorted_uv);

	vec3 tinted = mix(screen_color.rgb, tint_color.rgb, tint_strength);

	if (enable_caustics) {
		vec2 caustic_uv = distorted_uv * caustic_scale + vec2(TIME * caustic_speed, TIME * caustic_speed * 0.5);
		float caustic = noise(caustic_uv);
		caustic = smoothstep(0.6, 1.0, caustic);
		tinted += vec3(caustic) * caustic_strength;
	}

	float dist = distance(uv, vec2(0.5));
	float vignette = smoothstep(vignette_radius, vignette_radius - 0.4, dist);
	tinted *= mix(1.0 - vignette_strength, 1.0, vignette);

	COLOR = vec4(tinted, screen_color.a);
}