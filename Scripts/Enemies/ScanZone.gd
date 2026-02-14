extends Area2D

## Enhanced Scan Zone created by Antivirus
## Improved visual feedback, sound cues, and progressive warning

# ========================
# ENUMS
# ========================
enum State { WARNING, SCANNING }

# ========================
# EXPORTS
# ========================
@export var warning_duration := 2.0
@export var scan_duration := 1.5
@export var damage_per_tick := 25  # Damage dealt per 0.5 seconds

# ========================
# CONSTANTS
# ========================
const WARNING_COLOR := Color(1.0, 0.5, 0.2, 0.4)
const SCAN_COLOR := Color(1.0, 0.0, 0.0, 0.8)

const SCALE_PER_THREAT := {
	GameManager.ThreatLevel.LOW: Vector2(3.0, 3.0),
	GameManager.ThreatLevel.MEDIUM: Vector2(4.0, 4.0),
	GameManager.ThreatLevel.CRITICAL: Vector2(5.0, 5.0)
}

const PULSE_SPEED := 5.0
const FINAL_WARNING_THRESHOLD := 0.5  # Last 0.5 seconds flash rapidly

# ========================
# STATE
# ========================
var current_state := State.WARNING
var state_timer := 0.0
var is_virus_inside := false
var infected_targets: Array[Infectable] = []
var damage_timer := 0.0

# ========================
# VISUAL
# ========================
@onready var sprite: Sprite2D = $Sprite2D
@onready var warning_ring: Sprite2D = $WarningRing
@onready var particles: GPUParticles2D = $Particles

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	_setup_appearance()
	_connect_signals()
	_emit_events()

func _setup_appearance() -> void:
	"""Setup initial appearance based on threat level"""
	modulate = WARNING_COLOR
	
	var threat_level := GameManager.get_threat_level()
	scale = SCALE_PER_THREAT.get(threat_level, Vector2(3.0, 3.0))
	
	# Setup warning ring if exists
	if warning_ring:
		warning_ring.modulate = Color(1, 0.5, 0, 0.8)
		warning_ring.scale = Vector2(1.2, 1.2)

func _connect_signals() -> void:
	"""Connect area and body signals"""
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)

func _emit_events() -> void:
	"""Emit EventBus events"""
	EventBus.scan_started.emit(self)
	EventBus.emit_notification("⚠️ Scan Détecté!", "warning")

func _process(delta: float) -> void:
	state_timer += delta
	
	match current_state:
		State.WARNING:
			_update_warning_phase(delta)
			if state_timer >= warning_duration:
				_start_scanning()
		
		State.SCANNING:
			_update_scanning_phase(delta)
			if state_timer >= scan_duration:
				queue_free()

# ========================
# WARNING PHASE
# ========================
func _update_warning_phase(delta: float) -> void:
	"""Update warning visual effects"""
	var time_remaining := warning_duration - state_timer
	
	# Progressive color change (orange -> red)
	var progress := state_timer / warning_duration
	var warning_color := WARNING_COLOR.lerp(Color(1, 0, 0, 0.6), progress)
	modulate = warning_color
	
	# Pulse effect (faster as time runs out)
	var pulse_frequency := PULSE_SPEED * (1.0 + progress * 2.0)
	var pulse: Variant = abs(sin(state_timer * pulse_frequency))
	modulate.a = 0.3 + pulse * 0.3
	
	# Warning ring pulse
	if warning_ring:
		warning_ring.scale = Vector2(1.2, 1.2) + Vector2(pulse * 0.2, pulse * 0.2)
		warning_ring.modulate.a = pulse
	
	# Final warning - rapid flash
	if time_remaining < FINAL_WARNING_THRESHOLD:
		var rapid_flash := int(time_remaining * 20.0) % 2
		modulate.a = 0.3 if rapid_flash == 0 else 0.8
		
		# Alert sound (would be implemented in AudioManager)
		if int(time_remaining * 10.0) % 5 == 0:
			EventBus.emit_screen_shake(0.1, 0.05)

# ========================
# SCANNING PHASE
# ========================
func _start_scanning() -> void:
	"""Transition from warning to scanning state"""
	current_state = State.SCANNING
	state_timer = 0.0
	modulate = SCAN_COLOR
	
	# Hide warning ring
	if warning_ring:
		warning_ring.visible = false
	
	# Activate particles
	if particles:
		particles.emitting = true
	
	# Strong screen shake
	EventBus.emit_screen_shake(0.6, 0.3)
	EventBus.emit_notification("🚨 SCAN EN COURS!", "error")

func _update_scanning_phase(delta: float) -> void:
	"""Update scanning effects and deal damage"""
	# Intense pulsing
	var pulse: Variant = abs(sin(state_timer * 15.0))
	modulate.a = 0.6 + pulse * 0.4
	
	# Scale pulsing
	var base_scale: Variant = SCALE_PER_THREAT.get(GameManager.get_threat_level(), Vector2(3.0, 3.0))
	scale = base_scale * (1.0 + pulse * 0.1)
	
	# Deal damage periodically
	damage_timer += delta
	if damage_timer >= 0.5:
		_perform_cleaning()
		damage_timer = 0.0
		EventBus.emit_screen_shake(0.3, 0.1)

# ========================
# SCANNING/CLEANING
# ========================
func _perform_cleaning() -> void:
	"""Clean infected targets and damage virus if present"""
	var cleaned_count := 0
	
	# Damage virus if inside scan zone
	if is_virus_inside:
		_damage_virus()
	
	# Clean all infected targets
	for target in infected_targets:
		if is_instance_valid(target):
			_clean_target(target)
			cleaned_count += 1
	
	infected_targets.clear()
	
	if cleaned_count > 0:
		EventBus.scan_completed.emit(self, cleaned_count)

func _damage_virus() -> void:
	"""Damage the virus"""
	if is_instance_valid(GameManager.virus_node):
		GameManager.virus_node.take_damage(damage_per_tick)

func _clean_target(target: Infectable) -> void:
	"""Clean an infected target"""
	if target.is_infected:
		target.queue_free()

# ========================
# DETECTION
# ========================
func _on_body_entered(body: Node) -> void:
	"""Detect virus entering scan zone"""
	if body.is_in_group("virus"):
		is_virus_inside = true
		if current_state == State.WARNING:
			EventBus.emit_notification("⚠️ Virus Détecté dans la Zone!", "warning")

func _on_body_exited(body: Node) -> void:
	"""Detect virus leaving scan zone"""
	if body.is_in_group("virus"):
		is_virus_inside = false

func _on_area_entered(area: Area2D) -> void:
	"""Detect infected targets in scan zone"""
	if area is Infectable and area.is_infected:
		infected_targets.append(area)
