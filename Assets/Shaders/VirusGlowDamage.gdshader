shader_type canvas_item;

// ========================
// VIRUS DAMAGE GLOW SHADER
// Red pulsating glow when taking damage
// ========================

// Glow parameters
uniform vec4 glow_color : source_color = vec4(1.0, 0.2, 0.2, 1.0); // Red
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5;

// Damage flash parameters
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.8;
uniform float flash_speed : hint_range(0.0, 20.0) = 10.0;

// Glitch effect
uniform bool enable_glitch = true;
uniform float glitch_intensity : hint_range(0.0, 0.1) = 0.05;

void fragment() {
	vec2 uv = UV;
	
	// Glitch effect
	if (enable_glitch) {
		// Horizontal glitch lines
		float glitch = step(0.98, sin(UV.y * 100.0 + TIME * 50.0));
		uv.x += glitch * glitch_intensity * sin(TIME * 20.0);
	}
	
	// Get texture color
	vec4 tex_color = texture(TEXTURE, uv);
	
	// Fast damage pulse
	float pulse = (sin(TIME * flash_speed) + 1.0) / 2.0;
	pulse = pow(pulse, 3.0); // Make it more punchy
	
	// Base color
	vec3 final_color = tex_color.rgb;
	float alpha = tex_color.a;
	
	// Red damage overlay
	if (alpha > 0.1) {
		// Flash white-red
		vec3 flash_color = mix(glow_color.rgb, vec3(1.0, 1.0, 1.0), pulse * flash_intensity);
		final_color = mix(final_color, flash_color, flash_intensity * pulse);
		
		// Add red glow
		final_color += glow_color.rgb * glow_intensity * pulse * alpha;
	}
	
	// Output
	COLOR = vec4(final_color, alpha);
}
