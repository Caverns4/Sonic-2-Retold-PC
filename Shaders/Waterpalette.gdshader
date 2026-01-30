shader_type canvas_item;
// NOTE: palette sizes has to be to the power of 2
uniform float amount : hint_range(1,255,1);
uniform sampler2D originalPalette : filter_nearest;
uniform sampler2D swapPalette : filter_nearest;
uniform float speed = 2.0;
uniform float waves = 30.0;
uniform float magnitude = 0.25;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

float Remap01(float value, float from, float to) {
	return (value - from) / (to - from);
}

void fragment(){
	vec2 uv = SCREEN_UV;
	uv.x += (Remap01(sin(uv.y * waves - (TIME * speed)), -waves, waves) - 0.5)*magnitude;
	vec4 screen = textureLod(SCREEN_TEXTURE, uv, 0.0);

	vec3 color = screen.rgb;
	vec3 pal = texture(originalPalette,vec2(0,0)).rgb;
	vec3 swap_pal = texture(originalPalette,vec2(0,0)).rgb;
	vec3 new_color = pal;
	vec3 remap_color = pal;

	for (float i = 0.0; i<=amount; i++){
		pal = texture(originalPalette,vec2(i/amount,0)).rgb;
		swap_pal = texture(swapPalette,vec2(i/amount,0)).rgb;

		if (distance(pal, color) < distance(new_color, color)) {
			new_color = pal;
			remap_color = swap_pal;

		}
	}

	COLOR.rgb = remap_color;
	COLOR.a  = texture(TEXTURE,UV).a;
}