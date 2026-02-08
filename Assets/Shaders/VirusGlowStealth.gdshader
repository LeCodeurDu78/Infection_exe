shader_type canvas_item;

// ========================
// VIRUS STEALTH SHADER
// Translucent ghost effect for invisibility
// ========================

// Stealth parameters
uniform float opacity : hint_range(0.0, 1.0) = 0.3;
uniform vec4 ghost_color : source_color = vec4(0.0, 1.0, 0.8, 0.5); // Cyan-ish
uniform float ghost_intensity : hint_range(0.0, 2.0) = 0.5;

// Shimmer effect
uniform bool enable_shimmer = true;
uniform float shimmer_speed : hint_range(0.0, 10.0) = 3.0;
uniform float shimmer_scale : hint_range(1.0, 20.0) = 8.0;

// Edge outline
uniform bool enable_outline = true;
uniform float outline_width : hint_range(0.0, 0.3) = 0.1;
uniform vec4 outline_color : source_color = vec4(0.0, 1.0, 0.8, 1.0);

void fragment() {
	// Get texture color
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Shimmer pattern
	float shimmer = 1.0;
	if (enable_shimmer) {
		vec2 shimmer_uv = UV * shimmer_scale;
		shimmer = (sin(shimmer_uv.x + TIME * shimmer_speed) + 
		          sin(shimmer_uv.y - TIME * shimmer_speed * 0.7) + 2.0) / 4.0;
	}
	
	// Ghost effect
	vec3 final_color = mix(tex_color.rgb, ghost_color.rgb, ghost_intensity * shimmer);
	float alpha = tex_color.a * opacity;
	
	// Edge outline for visibility
	if (enable_outline && tex_color.a > 0.1) {
		vec2 center = vec2(0.5, 0.5);
		float dist = distance(UV, center);
		float edge = smoothstep(0.5 - outline_width, 0.5, dist);
		
		// Add outline
		final_color = mix(final_color, outline_color.rgb, edge * outline_color.a);
		alpha = max(alpha, edge * outline_color.a * 0.8);
	}
	
	// Output
	COLOR = vec4(final_color, alpha);
}
