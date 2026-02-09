extends Node2D

## Particle Manager
## Manages all particle effects in the game using EventBus
## Automatically spawns particles based on game events

# ========================
# PARTICLE SCENES
# ========================
var particle_scenes := {
	"infection": preload("res://Scenes/Particles/InfectionParticles.tscn"),
	"level_up": preload("res://Scenes/Particles/LevelUpParticles.tscn"),
	"virus_hit": preload("res://Scenes/Particles/HitParticles.tscn"),
	"mutation_activated": preload("res://Scenes/Particles/MutationParticles.tscn"),
	"scan_wave": preload("res://Scenes/Particles/ScanWaveParticles.tscn"),
	"dash_trail": preload("res://Scenes/Particles/DashTrailParticles.tscn"),
	"propagation": preload("res://Scenes/Particles/PropagationParticles.tscn"),
}

# ========================
# STATE
# ========================
var active_particles: Array[GPUParticles2D] = []

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	_connect_events()

func _connect_events() -> void:
	"""Connect to all relevant EventBus signals"""
	
	# Infection events
	EventBus.infection_started.connect(_on_infection_started)
	EventBus.infection_completed.connect(_on_infection_completed)
	
	# Virus events
	EventBus.virus_leveled_up.connect(_on_virus_level_up)
	EventBus.virus_damaged.connect(_on_virus_damaged)
	
	# Mutation events
	EventBus.mutation_activated.connect(_on_mutation_activated)
	
	# Antivirus events
	EventBus.scan_launched.connect(_on_scan_launched)

# ========================
# EVENT HANDLERS
# ========================

func _on_infection_started(target: Node, _points: int) -> void:
	if is_instance_valid(target):
		spawn_particle("infection", target.global_position, 0.8)

func _on_infection_completed(_position: Vector2, _points: int) -> void:
	spawn_particle("infection", _position, 1.2)
	spawn_particle("propagation", _position, 1.0)

func _on_virus_level_up(_new_level: int) -> void:
	if is_instance_valid(GameManager.virus_node):
		spawn_particle("level_up", GameManager.virus_node.global_position, 1.5)

func _on_virus_damaged(amount: int, _remaining_health: int) -> void:
	if is_instance_valid(GameManager.virus_node):
		var intensity = clamp(amount / 20.0, 0.5, 2.0)
		spawn_particle("virus_hit", GameManager.virus_node.global_position, intensity)

func _on_mutation_activated(_mutation: Mutation) -> void:
	if is_instance_valid(GameManager.virus_node):
		spawn_particle("mutation_activated", GameManager.virus_node.global_position, 1.0)

func _on_scan_launched(_position: Vector2, scale_vec: Vector2) -> void:
	var scale_factor = (scale_vec.x + scale_vec.y) / 2.0
	spawn_particle("scan_wave", _position, scale_factor)

# ========================
# PARTICLE SPAWNING
# ========================

func spawn_particle(particle_type: String, _position: Vector2, scale_factor: float = 1.0) -> void:
	"""Spawn a particle effect at the given position"""
	if particle_type not in particle_scenes:
		push_warning("ParticleManager: Unknown particle type '%s'" % particle_type)
		return
	
	var particle: GPUParticles2D = particle_scenes[particle_type].instantiate()
	particle.global_position = _position
	particle.scale *= scale_factor
	particle.emitting = true
	
	# Add to scene
	get_tree().current_scene.add_child(particle)
	active_particles.append(particle)
	
	# Auto-cleanup when finished
	_schedule_cleanup(particle)

func _schedule_cleanup(particle: GPUParticles2D) -> void:
	"""Remove particle after it finishes emitting"""
	# Wait for lifetime + a bit extra
	var lifetime = particle.lifetime
	var wait_time = lifetime * 2.0 # Double to ensure all particles fade out
	
	await get_tree().create_timer(wait_time).timeout
	
	if is_instance_valid(particle):
		active_particles.erase(particle)
		particle.queue_free()

# ========================
# MANUAL SPAWNING (for mutations or special effects)
# ========================

func spawn_dash_trail(_position: Vector2) -> void:
	"""Spawn a dash trail particle (called continuously during dash)"""
	spawn_particle("dash_trail", _position, 0.6)

func spawn_custom_particle(particle_type: String, _position: Vector2, scale_factor: float = 1.0, _custom_color: Color = Color.WHITE) -> void:
	"""Spawn a particle with custom color"""
	spawn_particle(particle_type, _position, scale_factor)
	
	# Note: To customize color, you'd need to modify the particle's material
	# This is a placeholder for future enhancement

# ========================
# CLEANUP
# ========================

func clear_all_particles() -> void:
	"""Remove all active particles (useful for scene transitions)"""
	for particle in active_particles:
		if is_instance_valid(particle):
			particle.queue_free()
	active_particles.clear()
