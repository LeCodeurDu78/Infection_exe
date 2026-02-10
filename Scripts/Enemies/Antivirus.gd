extends CharacterBody2D

## Enemy AI - Antivirus
## Patrols, chases virus, and performs scans

# ========================
# ENUMS
# ========================
enum State { WANDER, CHASE }

# ========================
# EXPORTS
# ========================
@export var base_speed := 200.0
@export var scan_scene: PackedScene
@export var scan_cooldown := 4.0
@export var damage := 75
@export var detection_radius := Vector2(20, 20)

# ========================
# STATE
# ========================
var current_state := State.WANDER
var chase_target: Node2D = null

# Wander state
var wander_direction := Vector2.ZERO
var wander_timer := 0.0

# Scan state
var scan_timer := 0.0

# ========================
# REFERENCES
# ========================
@onready var detection_area: Area2D = $DetectionArea

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	randomize()
	_pick_new_wander_direction()
	
	# Connect signals
	if detection_area:
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
	
	# Connect to EventBus
	EventBus.threat_level_changed.connect(_on_threat_level_changed)

func _physics_process(delta: float) -> void:
	_update_detection_radius()
	_update_scan_timer(delta)
	_update_movement(delta)
	move_and_slide()

# ========================
# DETECTION
# ========================
func _update_detection_radius() -> void:
	"""Update detection area based on virus discretion"""
	if is_instance_valid(GameManager.virus_node):
		detection_area.scale = detection_radius * GameManager.virus_node.discretion

func _on_detection_body_entered(body: Node2D) -> void:
	"""Handle virus detection"""
	if body.is_in_group("virus") and not body.is_invisible:
		chase_target = body
		current_state = State.CHASE
		EventBus.antivirus_detected_virus.emit(self, body)

func _on_detection_body_exited(body: Node2D) -> void:
	"""Handle virus leaving detection"""
	if body == chase_target:
		EventBus.antivirus_lost_virus.emit(self)
		chase_target = null
		current_state = State.WANDER

# ========================
# SCANNING
# ========================
func _update_scan_timer(delta: float) -> void:
	"""Update scan timer and trigger scans"""
	scan_timer += delta
	
	if scan_timer >= scan_cooldown:
		_perform_scan()
		scan_timer = 0.0

func _perform_scan() -> void:
	"""Launch a scan at target location"""
	if not scan_scene or not is_instance_valid(chase_target):
		return
	
	var scan := scan_scene.instantiate()
	scan.global_position = chase_target.global_position
	get_parent().add_child(scan)
	
	EventBus.emit_screen_shake(0.5, 0.2)
	EventBus.scan_launched.emit(chase_target.global_position, scan.scale)

# ========================
# MOVEMENT
# ========================
func _update_movement(delta: float) -> void:
	"""Update movement based on current state"""
	match current_state:
		State.WANDER:
			_update_wander(delta)
		State.CHASE:
			_update_chase()

func _update_wander(delta: float) -> void:
	"""Wander randomly"""
	wander_timer -= delta
	
	if wander_timer <= 0.0:
		_pick_new_wander_direction()
	
	velocity = wander_direction * base_speed * _get_speed_multiplier()

func _pick_new_wander_direction() -> void:
	"""Pick a new random direction for wandering"""
	wander_direction = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()
	wander_timer = randf_range(1.0, 3.0)

func _update_chase() -> void:
	"""Chase the virus"""
	if not is_instance_valid(chase_target) or chase_target.is_invisible:
		chase_target = null
		current_state = State.WANDER
		return
	
	var direction := (chase_target.global_position - global_position).normalized()
	velocity = direction * base_speed * _get_speed_multiplier()

func slow_down(enable: bool) -> void:
	"""Apply or remove slowing effect"""
	if enable:
		base_speed *= 0.5
	else:
		base_speed *= 2.0

# ========================
# DIFFICULTY
# ========================
func _get_speed_multiplier() -> float:
	"""Get speed multiplier based on threat level"""
	match GameManager.get_threat_level():
		GameManager.ThreatLevel.LOW:
			return 1.0
		GameManager.ThreatLevel.MEDIUM:
			return 1.3
		GameManager.ThreatLevel.CRITICAL:
			return 1.7
	return 1.0

func _on_threat_level_changed(_old_level: GameManager.ThreatLevel, _new_level: GameManager.ThreatLevel) -> void:
	"""React to threat level changes"""
	# Could add visual feedback or behavior changes here
	pass

# ========================
# COLLISION
# ========================
func _on_body_entered(body: Node) -> void:
	"""Handle collision with virus"""
	if body.is_in_group("virus"):
		EventBus.emit_screen_shake(0.75, 0.2)
		body.take_damage(damage)
		queue_free()
