shader_type canvas_item;

// ========================
// VIRUS GLOW INTENSE SHADER
// Super intense glow for level ups and special moments
// ========================

// Glow parameters
uniform vec4 glow_color : source_color = vec4(0.2, 1.0, 1.0, 1.0); // Cyan
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.5;
uniform float glow_spread : hint_range(0.0, 3.0) = 2.0;

// Pulsation parameters
uniform float pulse_speed : hint_range(0.0, 20.0) = 8.0;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.5;
uniform float pulse_max : hint_range(1.0, 3.0) = 2.0;

// Wave effect
uniform bool enable_wave = true;
uniform float wave_speed : hint_range(0.0, 10.0) = 5.0;
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.3;

// Distortion
uniform bool enable_distortion = false;
uniform float distortion_amount : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	// UV with optional distortion
	vec2 uv = UV;
	
	if (enable_distortion) {
		float distort_x = sin(TIME * 3.0 + UV.y * 10.0) * distortion_amount;
		float distort_y = cos(TIME * 2.0 + UV.x * 10.0) * distortion_amount;
		uv += vec2(distort_x, distort_y);
	}
	
	// Get texture color
	vec4 tex_color = texture(TEXTURE, uv);
	
	// Fast pulsation
	float pulse = mix(pulse_min, pulse_max, (sin(TIME * pulse_speed) + 1.0) / 2.0);
	
	// Wave effect
	float wave = 1.0;
	if (enable_wave) {
		vec2 center = vec2(0.5, 0.5);
		float dist = distance(UV, center);
		wave = 1.0 + sin(dist * 10.0 - TIME * wave_speed) * wave_amplitude;
	}
	
	// Base color
	vec3 final_color = tex_color.rgb;
	float alpha = tex_color.a;
	
	// Intense glow
	if (alpha > 0.1) {
		final_color += glow_color.rgb * glow_intensity * pulse * wave * alpha;
		
		// Extra outer glow
		vec2 center = vec2(0.5, 0.5);
		float dist = distance(UV, center);
		float outer_glow = exp(-dist * 2.0) * glow_spread;
		final_color += glow_color.rgb * outer_glow * pulse;
	}
	
	// Output
	COLOR = vec4(final_color, alpha);
}
