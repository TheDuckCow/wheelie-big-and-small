shader_type spatial;
render_mode ambient_light_disabled;

uniform float speed;
uniform float angle;
uniform vec4 col: source_color = vec4(0.8, 0.8, 0.8, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
}

mat2 rotate(float theta) {
	return mat2(vec2(cos(theta), -sin(theta)),
	            vec2(sin(theta), cos(theta)));
}

float spherical_to_linear(float x) {
	return 1.0f - sqrt(1.0f - x*x);
}

#if 1
void light() {
	float new_angle = angle*TAU;
	vec2 direction = vec2(cos(angle), sin(angle));
	vec2 coords = rotate(angle*TAU)*((FRAGCOORD.xy-VIEWPORT_SIZE.xy*0.5f)/VIEWPORT_SIZE.x);
	float line = coords.x + sin(coords.y*TAU*6.0f)/32.0;
	line = fract(line*128.0f);
	float light = clamp(dot(NORMAL, LIGHT), 0.0f, 1.0f);
	if (spherical_to_linear(light) >line || ATTENUATION > 0.5) {
		DIFFUSE_LIGHT += light*LIGHT_COLOR*col.xyz;
	}
}
#endif
