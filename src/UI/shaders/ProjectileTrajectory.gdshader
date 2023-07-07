shader_type canvas_item;

uniform float speed = 1000.0;
uniform float opacity = 0.5f;
uniform vec3 color = vec3(1.0f, 1.0f, 1.0f);

void fragment() {
	vec2 moving_uv = vec2(UV.x + TIME * speed, UV.y);
	vec4 finalCol = vec4(color, 1) * texture(TEXTURE, moving_uv);
	COLOR = vec4(finalCol.xyz, opacity * finalCol.a);
}
