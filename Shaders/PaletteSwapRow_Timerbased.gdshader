shader_type canvas_item;
uniform float amount : hint_range(1,255,1);
uniform float palRows : hint_range(1,255,1);
//uniform float row : hint_range(1,999,1);
uniform float approximation : hint_range(0.0,5.0,0.01);
uniform sampler2D paletteTexture : filter_nearest;
uniform float time_scale: hint_range(0.0, 10.0, 0.01) = 5.0;

void fragment(){
	float fac = TIME/(time_scale);
	float row = mod(round(fac),round(palRows));

	if (row > 0.0) {
		vec3 pal = texture(paletteTexture,UV).rgb;
		vec3 repal = pal;
		vec3 color = texture(TEXTURE,UV).rgb;

		vec3 new_color = color;

		for (float i = 1.0; i<=amount; i++){
			pal = texture(paletteTexture,vec2(i/(amount+1.0),0)).rgb;
			repal = texture(paletteTexture,vec2(i/(amount+1.0),(row)/(palRows))).rgb;

			if (distance(pal,color) - distance(new_color, color) <= approximation) {
				new_color = repal;
				// set i to end loop if a match was already found
				i = amount+1.0;
			}
		}

		COLOR.rgb = new_color;
		COLOR.a  = texture(TEXTURE,UV).a;
	} else {
	COLOR = texture(TEXTURE,UV).rgba;
	}
}