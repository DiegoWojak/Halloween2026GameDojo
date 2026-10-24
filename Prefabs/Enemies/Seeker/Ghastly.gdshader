shader_type canvas_item;

uniform sampler2D main_tex : source_color, repeat_enable;

// modulate del nodo (p. ej. alpha 0.1 con la linterna apagada); COLOR del fragment lo pisa
varying vec4 node_modulate;

void vertex() {
	node_modulate = COLOR;
}

float body(vec2 p)
{
	vec2 o = vec2(0.47, 0.48);
	float r = 0.06;
	float x = p.x - o.x;
	float y = p.y - o.y;
	float q  = float((x*x + y*y) < r);
	return q;
}

float smoke(vec2 p, float n)
{
	float noise = n;
	float x = p.x - 0.5;
	float y = p.y - 0.5;
	return float(0.35 * noise + (x*x + y*y) < 0.20);
}

float left_eye(vec2 p, float t)
{
	float vx = 0.9;
	float vy = 1.0;
	float r = 0.022;
	vec2 o = vec2(0.54, 0.54);
	float x = p.x - o.x;
	float y = p.y - o.y;
	float q = float(((x*x)/(vx*vx) + (y*y)/vy)>r);
	bool edge = bool(p.y - 0.02 - t * 0.2 < p.x);
	return (edge) ? q : 1.0;
}

float right_eye(vec2 p, float t)
{
	float vx = 0.6;
	float vy = 1.0;
	float r = 0.022;
	vec2 o = vec2(0.3, 0.54);
	float x = p.x - o.x;
	float y = p.y - o.y;
	float q = float(((x*x)/(vx*vx) + (y*y)/vy)>r);
	bool edge = bool(p.y < 0.2 * t + 1.0 - p.x * 1.5);
	return (edge) ? q : 1.0;
}

float left_pupil(vec2 p, float t)
{
	float vx = 1.0;
	float vy = 4.0;
	float r = 0.00002;
	vec2 o = vec2(0.516, 0.48);
	float x = p.x - o.x;
	float y = p.y - o.y;
	float q = float(((x*x)/(vx) + (y*y)/(vy*vy)) > max(r, t * 0.00004));
	return q;
}

float right_pupil(vec2 p, float t)
{
	float vx = 1.0;
	float vy = 4.0;
	float r = 0.00002;
	vec2 o = vec2(0.305, 0.48);
	float x = p.x - o.x;
	float y = p.y - o.y;
	float q = float(((x*x)/(vx) + (y*y)/(vy*vy)) > max(r, t * 0.00004));
	return q;
}

float mouth_shape(vec2 p)
{
	float vx = 1.1;
	float vy = 1.0;
	float r = 0.04;
	vec3 o = vec3(0.45, 0.49, 0.54);
	float x = p.x - o.x;
	float y = p.y - o.y;
	float yy = p.y - o.z;
	float q = float(((x*x) / (vx*vx) + (y*y)/vy) > r);
	bool edge = bool(((x*x) / (1.5*1.5) + (yy*yy)/vy )> r);
	return (edge) ? q : 1.0;
}

float left_canine(vec2 p)
{
	float vx = 1.1;
	float vy = 1.0;
	float r = 0.04;
	vec3 o = vec3(0.45, 0.49, 0.54);
	float x = p.x - o.x;
	float y = p.y - o.y;
	float yy = p.y - o.z;
	float q = float(((x*x) / (vx*vx) + (y*y)/vy) > r);
	bool edge = bool(((x*x) / (1.5*1.5) + (yy*yy)/vy )> r);
	bool edge_y = bool(p.y < 0.5);
	float m = float(p.y - 0.32 > abs(3.0 * p.x - 0.91));
	return (edge && edge_y) ? m : 0.0;
}

float right_canine(vec2 p)
{
	float vx = 1.1;
	float vy = 1.0;
	float r = 0.04;
	vec3 o = vec3(0.45, 0.49, 0.54);
	float x = p.x - o.x;
	float y = p.y - o.y;
	float yy = p.y - o.z;
	float q = float(((x*x) / (vx*vx) + (y*y)/vy) > r);
	bool edge = bool(((x*x) / (1.5*1.5) + (yy*yy)/vy )> r);
	bool edge_y = bool(p.y < 0.5);
	float m = float(p.y - 0.29 > abs(2.5 * p.x - 1.4));
	return (edge && edge_y) ? m : 0.0;
}

void fragment() {
	float t = TIME * 0.26;
	float s1 = sin(0.5 + t * 10.0) * 0.1;
	float s2 = sin(t * 10.0) * 0.1;
	vec2 uv = vec2(UV.x, 1.0 - UV.y + s1);

	float body_shape = body(uv);
	float left_eye_shape = 1.0 - left_eye(uv, s2);
	float right_eye_shape = 1.0 - right_eye(uv, s2);
	float left_pupil_shape = left_pupil(uv, s2);
	float right_pupil_shape = right_pupil(uv,s2);
	float mouth_shape = 1.0 - mouth_shape(uv);
	float left_canine_shape = left_canine(uv);
	float right_canine_shape = right_canine(uv);
	float smoke_shape = smoke(uv, texture(main_tex, UV + vec2(-t, t)).r);

	float c = 255.0;
	vec3 smoke_color = vec3(124.0/c, 110.0/c, 187.0/c);
	vec3 body_color = vec3(5.0/c , 0.0, 65.0/c);
	vec3 mouth_color = vec3(255.0/c, 65.0/c, 65.0/c);

	vec3 render = vec3(0.0);
	render += smoke_color * clamp(smoke_shape + body_shape, 0.0, 1.0);
	render *= mix(render, body_color, body_shape );
	render += left_eye_shape;
	render += right_eye_shape;
	render *= left_pupil_shape;
	render *= right_pupil_shape;
	render = mix(render, mouth_color, mouth_shape);
	render += left_canine_shape;
	render += right_canine_shape;
	render = clamp(render, 0.0 , 1.0);
	float alpha = clamp (smoke_shape + body_shape + right_eye_shape, 0.0, 1.0);

	COLOR = vec4(render, alpha) * node_modulate;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
