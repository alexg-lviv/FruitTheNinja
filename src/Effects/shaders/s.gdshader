shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float alpha = 0.0f;

void fragment() {
	vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);
	bg.r *= 0.9;
	bg.b *= 2.0;
	bg.g *= 0.9;
	
	vec2 uv = UV;
	
	uv *=  1.0 - uv.yx;   //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
	float vig = uv.x*uv.y * 15.0; // multiply with sth for intensity
	
	vig = pow(vig, 0.5); // change pow for modifying the extend of the  vignette
	
	COLOR.xyz = bg.xyz * vig;
	COLOR.a = alpha;
}
