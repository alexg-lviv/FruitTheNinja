shader_type canvas_item;

uniform vec2 cut_start;
uniform vec2 cut_end;
uniform float which_side;

void fragment() {
	vec2 cut_vector = cut_end - cut_start;
	float deform = sign((cut_end.x - cut_start.x) * (UV.y - cut_start.y) - (cut_end.y - cut_start.y) * (UV.x - cut_start.x));
	
	if (deform * which_side < 0.) {
		discard;
	}
}
