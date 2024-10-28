shader_type canvas_item;

// --- Uniforms --- //
uniform bool use_grayscale = true;
uniform vec4 shift_color: source_color;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b), float(use_grayscale));
	COLOR *= shift_color;
}
