shader_type canvas_item;

// ========================
// VIRUS GLOW SHADER
// Adds neon glow effect to the virus sprite
// ========================

// Glow parameters
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.0, 0.5); // Green neon
uniform float glow_intensity : hint_range(0.0, 3.0) = 0.3;
uniform float glow_spread : hint_range(0.0, 2.0) = 0.5;

// Pulsation parameters
uniform bool enable_pulse = true;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.7;
uniform float pulse_max : hint_range(1.0, 2.0) = 1.3;

// Edge glow parameters
uniform bool enable_edge_glow = false;
uniform float edge_thickness : hint_range(0.0, 0.5) = 0.15;

void fragment() {
	// Get texture color
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Calculate pulsation
	float pulse = 1.0;
	if (enable_pulse) {
		pulse = mix(pulse_min, pulse_max, (sin(TIME * pulse_speed) + 1.0) / 2.0);
	}
	
	// Base color with glow
	vec3 final_color = tex_color.rgb;
	float alpha = tex_color.a;
	
	// Add glow to colored areas
	if (alpha > 0.1) {
		final_color += glow_color.rgb * glow_intensity * pulse * alpha;
	}
	
	// Edge glow
	if (enable_edge_glow && alpha > 0.1) {
		// Calculate distance to edge
		vec2 center = vec2(0.5, 0.5);
		float dist = distance(UV, center);
		float edge_factor = smoothstep(0.5 - edge_thickness, 0.5, dist);
		
		// Add extra glow at edges
		final_color += glow_color.rgb * edge_factor * glow_intensity * pulse * 0.5;
	}
	
	// Output
	COLOR = vec4(final_color, alpha);
}
