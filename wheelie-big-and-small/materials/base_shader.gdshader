shader_type spatial;
render_mode ambient_light_disabled;

uniform float speed;
uniform float angle;
uniform float angle2;
uniform vec4 col: source_color = vec4(0.8f, 0.8f, 0.8f, 1.0f);
uniform vec4 col_dark: source_color = vec4(0.0f, 0.0f, 0.0f, 1.0f);
uniform vec4 col_light: source_color = vec4(1.0f, 1.0f, 1.0f, 1.0f);
uniform vec4 col_star: source_color = vec4(1.0f, 0.0f, 1.0f, 1.0f);
uniform sampler2D color_texture: source_color;
uniform sampler2D normal_map_texture;
uniform sampler2D noise_texture;


mat2 rotate(float theta) {
	return mat2(vec2(cos(theta), -sin(theta)),
	            vec2(sin(theta), cos(theta)));
}

//from https://iquilezles.org/articles/distfunctions2d/
float sdStar5(in vec2 p, in float r, in float rf)
{
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x,k1.y);
    p.x = abs(p.x);
    p -= 2.0*max(dot(k1,p),0.0)*k1;
    p -= 2.0*max(dot(k2,p),0.0)*k2;
    p.x = abs(p.x);
    p.y -= r;
    vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
    float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
    return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

float spherical_to_linear(float x) {
	return 1.0f - sqrt(1.0f - x*x);
}

float squoosh(float x, float offset, float amount) {
	return clamp(((x - offset)*amount)*0.5f + 0.5f, 0.0f, 1.0f);
}

float int_hash(int i){
	ivec2 size = textureSize(noise_texture, 0);
	ivec2 p = ivec2(i%size.x, (i/size.x)%size.y);
	return texelFetch(noise_texture, p, 0).x;
}

float hash(ivec2 p)
{
	return texelFetch(noise_texture, p%textureSize(noise_texture, 0), 0).x;
}

vec2 vec2_hash(ivec2 p) {
	ivec2 size = textureSize(noise_texture, 0);
	int i = p.x + p.y*size.x;
	return vec2(int_hash(i), int_hash(i + 137));
}

float voronoi_noise(vec2 p, float r) {
	ivec2 c = ivec2(floor(p));
	vec2 t = p - vec2(c);
	float f = 32.0f;
	for (int iy = -2;
	     iy < 2;
	     ++iy)
	{
		for (int ix = -2;
		     ix < 2;
		     ++ix)
		{
			ivec2 index = ivec2(ix, iy);
			vec2 o = vec2_hash(ivec2(c) + index)*r;
			vec2 op = t - o - vec2(index);
			float t = length(op);
			if (t < f){
				f = t;
			}
		}
	}
	return f;
}

vec2 voronoi_noise_coord(vec2 p, float r) {
	ivec2 c = ivec2(floor(p));
	vec2 t = p - vec2(c);
	float f = 32.0f;
	vec2 coord = vec2(0.0f, 0.0f);
	float theta = 0.0f;
	for (int iy = -2;
	     iy < 2;
	     ++iy)
	{
		for (int ix = -2;
		     ix < 2;
		     ++ix)
		{
			ivec2 index = ivec2(ix, iy);
			vec2 o = vec2_hash(ivec2(c) + index)*r;
			vec2 op = t - o - vec2(index);
			float t = length(op);
			if (t < f){
				f = t;
				coord = op;
				theta = o.x;
			}
		}
	}
	return rotate(theta*TAU)*coord;
}

varying float LINE;
varying float DOTS;
varying float STARS;

varying vec2 COORDS0;
varying vec2 COORDS1;

void fragment() {
	ALBEDO = texture(color_texture, UV).rgb;
	if (textureSize(normal_map_texture, 0).x > 16) {
		NORMAL_MAP = texture(normal_map_texture, UV).xyz;
	}

	COORDS0 = rotate(radians(angle))*((FRAGCOORD.xy-VIEWPORT_SIZE.xy*0.5f)/VIEWPORT_SIZE.x);
	COORDS1 = rotate(angle2)*COORDS0;

	float line_offset = sin(COORDS0.y*TAU*6.0f)/32.0f;
	float line = COORDS0.x + line_offset + FRAGCOORD.z*0.5f;
	LINE = abs(fract(line*128.0f)*2.0 - 1.0);

	DOTS = voronoi_noise((COORDS0 + vec2(FRAGCOORD.z*0.25f, 0.0f))*64.0, 0.5f)*4.0f;

	vec2 star_coords = voronoi_noise_coord((COORDS1 + vec2(FRAGCOORD.z*0.25f, 0.0f))*16.0f, 1.0f);
	float stars = sdStar5(star_coords*2.0f, 0.5f, 0.5f);
	STARS = 1.0f - squoosh(stars, 0.0f, 32.0f);
}

void light() {
	float light = dot(NORMAL, LIGHT);
	float light_sign = sign(light);
	light = abs(light);
	light = spherical_to_linear(light);
	light = light*light_sign*0.5f + 0.5f;

	float new_light = light;
	
	vec3 lit = light*ALBEDO*LIGHT_COLOR*col.rgb;

	vec3 light_color = mix(
		lit,
		col_light.rgb,
		(1.0f - squoosh(DOTS-new_light, 0.66666f, 8.0f))*col_light.a
	);

	light_color = mix(
		light_color,
		col_star.rgb*col.a,
		STARS*col_star.a
	);

	vec3 dark_color = mix(
		lit,
		col_dark.rgb,
		(1.0 - squoosh(1.0f - ((1.0f - ATTENUATION) - LINE*0.75f), 0.5, 16.0))*col_dark.a
	);

	DIFFUSE_LIGHT += mix(dark_color, light_color, squoosh(ATTENUATION, 1.0, 2.0));
}
