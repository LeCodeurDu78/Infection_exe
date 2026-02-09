extends Node

## Glow Controller
## Manages dynamic glow effects on the virus
## Switches between different shader materials based on game events

# ========================
# SHADER MATERIALS
# ========================
var glow_materials := {
	"normal": preload("res://Scenes/Shaders/VirusGlowMaterial.tres"),
	"intense": preload("res://Scenes/Shaders/VirusGlowIntenseMaterial.tres"),
	"damage": preload("res://Scenes/Shaders/VirusGlowDamageMaterial.tres"),
	"stealth": preload("res://Scenes/Shaders/VirusGlowStealthMaterial.tres"),
}

# ========================
# STATE
# ========================
@export var virus_sprite: Sprite2D
var current_state := "normal"
var original_material: ShaderMaterial
var damage_timer := 0.0
var intense_timer := 0.0

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:

	# Apply default glow material
	_apply_material("normal")
	original_material = glow_materials["normal"].duplicate()
	
	# Connect to EventBus
	_connect_events()

func _connect_events() -> void:
	"""Connect to game events"""
	EventBus.mutation_ui_closed.connect(_on_level_up)
	EventBus.virus_damaged.connect(_on_damaged)
	EventBus.mutation_activated.connect(_on_mutation_activated)

func _process(delta: float) -> void:
	# Handle timed effects
	if damage_timer > 0.0:
		damage_timer -= delta
		if damage_timer <= 0.0:
			_apply_material("normal")
	
	if intense_timer > 0.0:
		intense_timer -= delta
		if intense_timer <= 0.0:
			_apply_material("normal")

# ========================
# EVENT HANDLERS
# ========================

func _on_level_up(_mutation: Mutation) -> void:
	"""Flash intense glow on level up"""
	_apply_material("intense")
	intense_timer = 2.0 # 2 seconds of intense glow

func _on_damaged(_amount: int, _remaining_health: int) -> void:
	"""Flash red damage glow"""
	_apply_material("damage")
	damage_timer = 0.5 # 0.5 seconds of damage glow

func _on_mutation_activated(_mutation: Mutation) -> void:
	"""Brief intense glow on mutation activation"""
	_apply_material("intense")
	intense_timer = 0.2 # 0.2 second

# ========================
# MATERIAL MANAGEMENT
# ========================

func _apply_material(material_name: String) -> void:
	"""Apply a glow material to the virus sprite"""
	if material_name not in glow_materials:
		push_warning("GlowController: Unknown material '%s'" % material_name)
		return
	
	current_state = material_name
	virus_sprite.material = glow_materials[material_name].duplicate()

func set_stealth_mode(enabled: bool) -> void:
	"""Enable/disable stealth (invisibility) glow"""
	if enabled:
		_apply_material("stealth")
	else:
		_apply_material("normal")

# ========================
# MANUAL CONTROL (for mutations)
# ========================

func set_glow_intensity(intensity: float) -> void:
	"""Manually set glow intensity (0.0 - 3.0)"""
	if virus_sprite.material and virus_sprite.material is ShaderMaterial:
		virus_sprite.material.set_shader_parameter("glow_intensity", intensity)

func set_glow_color(color: Color) -> void:
	"""Manually set glow color"""
	if virus_sprite.material and virus_sprite.material is ShaderMaterial:
		virus_sprite.material.set_shader_parameter("glow_color", color)

func set_pulse_speed(speed: float) -> void:
	"""Manually set pulse speed (0.0 - 10.0)"""
	if virus_sprite.material and virus_sprite.material is ShaderMaterial:
		virus_sprite.material.set_shader_parameter("pulse_speed", speed)

# ========================
# EFFECTS
# ========================

func flash_glow(duration: float = 0.3, color: Color = Color.WHITE) -> void:
	"""Flash a custom color briefly"""
	var original_color = Color.GREEN
	if virus_sprite.material and virus_sprite.material is ShaderMaterial:
		original_color = virus_sprite.material.get_shader_parameter("glow_color")
	
	set_glow_color(color)
	await get_tree().create_timer(duration).timeout
	set_glow_color(original_color)

func pulse_glow(intensity: float, duration: float = 0.5) -> void:
	"""Pulse the glow intensity briefly"""
	var original_intensity = 1.0
	if virus_sprite.material and virus_sprite.material is ShaderMaterial:
		original_intensity = virus_sprite.material.get_shader_parameter("glow_intensity")
	
	set_glow_intensity(intensity)
	await get_tree().create_timer(duration).timeout
	set_glow_intensity(original_intensity)
