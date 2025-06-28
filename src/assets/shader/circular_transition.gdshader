shader_type canvas_item;

uniform float circle_rate:hint_range(0, 1);

void fragment()
{
	float dist = length(vec2(0.5, 0.5) - UV);
	if (dist < 0.707107 * circle_rate)
		COLOR.a = 0.0;
	else
		COLOR.a = 1.0;

	COLOR .rgb = vec3(0.0);
}
