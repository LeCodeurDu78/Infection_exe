extends Area2D

## Scan Zone created by Antivirus
## Warns then scans/cleans infected areas and destroys virus

# ========================
# ENUMS
# ========================
enum State { WARNING, SCANNING }

# ========================
# EXPORTS
# ========================
@export var warning_duration := 2.0
@export var scan_duration := 1.5

# ========================
# CONSTANTS
# ========================
const WARNING_COLOR := Color(1.0, 0.5, 0.2, 0.4)
const SCAN_COLOR := Color(1.0, 0.0, 0.0, 0.6)

const SCALE_PER_THREAT := {
	GameManager.ThreatLevel.LOW: Vector2(3.0, 3.0),
	GameManager.ThreatLevel.MEDIUM: Vector2(4.0, 4.0),
	GameManager.ThreatLevel.CRITICAL: Vector2(5.0, 5.0)
}

# ========================
# STATE
# ========================
var current_state := State.WARNING
var state_timer := 0.0
var is_virus_inside := false
var infected_targets: Array[Infectable] = []

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	_setup_appearance()
	_connect_signals()

func _setup_appearance() -> void:
	"""Setup initial appearance based on threat level"""
	modulate = WARNING_COLOR
	
	var threat_level := GameManager.get_threat_level()
	scale = SCALE_PER_THREAT.get(threat_level, Vector2(3.0, 3.0))

func _connect_signals() -> void:
	"""Connect area and body signals"""
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	state_timer += delta
	
	match current_state:
		State.WARNING:
			if state_timer >= warning_duration:
				_start_scanning()
		
		State.SCANNING:
			_perform_cleaning()
			if state_timer >= scan_duration:
				queue_free()

# ========================
# STATE TRANSITIONS
# ========================
func _start_scanning() -> void:
	"""Transition from warning to scanning state"""
	current_state = State.SCANNING
	state_timer = 0.0
	modulate = SCAN_COLOR

# ========================
# SCANNING/CLEANING
# ========================
func _perform_cleaning() -> void:
	"""Clean infected targets and destroy virus if present"""
	# Destroy virus if inside scan zone
	if is_virus_inside:
		_destroy_virus()
	
	# Clean all infected targets
	for target in infected_targets:
		if is_instance_valid(target):
			_clean_target(target)
	
	infected_targets.clear()

func _destroy_virus() -> void:
	"""Destroy the virus (game over)"""
	if is_instance_valid(GameManager.virus_node):
		GameManager.virus_node.queue_free()

func _clean_target(target: Infectable) -> void:
	"""Clean an infected target"""
	# Since Infectable destroys itself when infected,
	# we just need to ensure it's removed
	if target.is_infected:
		target.queue_free()

# ========================
# DETECTION
# ========================
func _on_body_entered(body: Node) -> void:
	"""Detect virus entering scan zone"""
	if body.is_in_group("virus"):
		is_virus_inside = true

func _on_body_exited(body: Node) -> void:
	"""Detect virus leaving scan zone"""
	if body.is_in_group("virus"):
		is_virus_inside = false

func _on_area_entered(area: Area2D) -> void:
	"""Detect infected targets in scan zone"""
	if area is Infectable and area.is_infected:
		infected_targets.append(area)
