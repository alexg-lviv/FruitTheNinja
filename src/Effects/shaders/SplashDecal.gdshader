shader_type canvas_item;

uniform vec3 col = vec3(1., 0., 0.);

void fragment() {
	vec4 texCol = texture(TEXTURE, UV);
	vec4 finalCol = vec4(col, 1) * vec4(vec3(1., 1., 1.) - texCol.rgb, texCol.a);
	COLOR.xyz = finalCol.xyz;
}
