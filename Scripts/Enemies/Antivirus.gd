extends CharacterBody2D

## Enhanced Enemy AI - Antivirus
## Advanced patrol patterns, coordinated attacks, predictive scans, and firewall deployment

# ========================
# ENUMS
# ========================
enum State { 
	PATROL,        # Follow predefined patrol route
	INVESTIGATE,   # Check last known virus position
	CHASE,         # Direct pursuit of virus
	COORDINATE,    # Coordinate with other antivirus
	DEPLOY_TRAP    # Deploy firewall/scan at strategic position
}

enum ScanType {
	REACTIVE,      # Scan at current virus position
	PREDICTIVE,    # Scan at predicted virus position
	AREA_SWEEP,    # Large area scan
	COORDINATED    # Synchronized scan with other antivirus
}

# ========================
# EXPORTS
# ========================
@export_group("Combat")
@export var base_speed := 200.0
@export var chase_speed_multiplier := 1.5
@export var damage := 75
@export var detection_radius := Vector2(20, 20)

@export_group("Scanning")
@export var scan_scene: PackedScene
@export var firewall_scene: PackedScene
@export var scan_cooldown := 4.0
@export var predictive_scan_enabled := true
@export var scan_prediction_time := 0.5  # Seconds to predict virus movement

@export_group("Intelligence")
@export var memory_duration := 5.0  # Seconds to remember last virus position
@export var coordination_radius := 300.0  # Radius to communicate with other antivirus
@export var trap_placement_enabled := true

# ========================
# STATE
# ========================
var current_state := State.PATROL
var chase_target: Node2D = null
var last_known_virus_position := Vector2.ZERO
var last_seen_timer := 0.0

# Patrol state
var patrol_points: Array[Vector2] = []
var current_patrol_index := 0
var patrol_wait_timer := 0.0
const PATROL_WAIT_TIME := 2.0
const PATROL_REACH_DISTANCE := 30.0

# Scan state
var scan_timer := 0.0
var can_scan := true
var scan_charges := 3  # Multiple scan charges
var scan_recharge_timer := 0.0
const SCAN_RECHARGE_TIME := 2.0

# Firewall deployment
var firewall_cooldown_timer := 0.0
const FIREWALL_COOLDOWN := 15.0
var firewalls_deployed := 0
const MAX_FIREWALLS := 2

# Coordination
var nearby_antivirus: Array[Node2D] = []
var is_coordinating := false

# ========================
# REFERENCES
# ========================
@onready var detection_area: Area2D = $DetectionArea
@onready var sprite: Sprite2D = $Sprite2D

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	randomize()
	_initialize_patrol_route()
	
	# Connect signals
	if detection_area:
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
	
	# Connect to EventBus
	EventBus.threat_level_changed.connect(_on_threat_level_changed)
	EventBus.virus_damaged.connect(_on_virus_damaged)
	
	# Add to antivirus group for coordination
	add_to_group("antivirus")

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_update_detection_radius()
	_update_nearby_antivirus()
	_update_state_machine(delta)
	_update_visual_feedback()
	move_and_slide()

# ========================
# INITIALIZATION
# ========================
func _initialize_patrol_route() -> void:
	"""Create a patrol route around spawn position"""
	var spawn_pos := global_position
	var patrol_radius := 200.0
	var num_points := 4
	
	for i in range(num_points):
		var angle := (TAU / num_points) * i
		var offset := Vector2(cos(angle), sin(angle)) * patrol_radius
		patrol_points.append(spawn_pos + offset)
	
	# Randomize starting point
	current_patrol_index = randi() % patrol_points.size()

# ========================
# STATE MACHINE
# ========================
func _update_state_machine(delta: float) -> void:
	"""Main AI state machine"""
	match current_state:
		State.PATROL:
			_state_patrol(delta)
		State.INVESTIGATE:
			_state_investigate(delta)
		State.CHASE:
			_state_chase(delta)
		State.COORDINATE:
			_state_coordinate(delta)
		State.DEPLOY_TRAP:
			_state_deploy_trap(delta)

func _state_patrol(delta: float) -> void:
	"""Patrol between predefined points"""
	if patrol_points.is_empty():
		_pick_random_wander()
		return
	
	var target_point := patrol_points[current_patrol_index]
	var direction := (target_point - global_position).normalized()
	var distance := global_position.distance_to(target_point)
	
	if distance < PATROL_REACH_DISTANCE:
		# Reached patrol point
		patrol_wait_timer += delta
		velocity = Vector2.ZERO
		
		if patrol_wait_timer >= PATROL_WAIT_TIME:
			patrol_wait_timer = 0.0
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			
			# 30% chance to deploy trap at patrol point
			if trap_placement_enabled and randf() < 0.3:
				_attempt_firewall_deployment()
	else:
		velocity = direction * base_speed * _get_speed_multiplier()

func _state_investigate(delta: float) -> void:
	"""Investigate last known virus position"""
	last_seen_timer += delta
	
	# Return to patrol if investigation takes too long
	if last_seen_timer > memory_duration:
		_transition_to_patrol()
		return
	
	var direction := (last_known_virus_position - global_position).normalized()
	var distance := global_position.distance_to(last_known_virus_position)
	
	if distance < 50.0:
		# Reached investigation point - perform area scan
		_perform_area_sweep()
		_transition_to_patrol()
	else:
		velocity = direction * base_speed * _get_speed_multiplier() * 1.2

func _state_chase(delta: float) -> void:
	"""Actively chase virus"""
	if not is_instance_valid(chase_target) or chase_target.is_invisible:
		last_known_virus_position = global_position if not is_instance_valid(chase_target) else chase_target.global_position
		_transition_to_investigate()
		return
	
	# Update last known position
	last_known_virus_position = chase_target.global_position
	last_seen_timer = 0.0
	
	# Calculate chase direction
	var direction := (chase_target.global_position - global_position).normalized()
	var distance := global_position.distance_to(chase_target.global_position)
	
	# Perform predictive scans when in range
	if can_scan and distance < 400.0:
		if predictive_scan_enabled and scan_charges > 0:
			_perform_predictive_scan()
		elif scan_charges > 0:
			_perform_reactive_scan()
	
	# Deploy firewall to cut off escape routes
	if trap_placement_enabled and distance < 300.0 and distance > 150.0:
		_attempt_firewall_deployment()
	
	# Check if should coordinate with nearby antivirus
	if not nearby_antivirus.is_empty() and distance < 500.0:
		_transition_to_coordinate()
		return
	
	velocity = direction * base_speed * chase_speed_multiplier * _get_speed_multiplier()

func _state_coordinate(delta: float) -> void:
	"""Coordinate attack with other antivirus"""
	if not is_instance_valid(chase_target) or chase_target.is_invisible:
		_transition_to_investigate()
		return
	
	if nearby_antivirus.is_empty():
		_transition_to_chase()
		return
	
	# Pincer movement - flank from different angles
	var allies_positions := _get_allies_positions()
	var optimal_position := _calculate_flanking_position(allies_positions)
	
	var direction := (optimal_position - global_position).normalized()
	velocity = direction * base_speed * _get_speed_multiplier()
	
	# Perform coordinated scan
	if can_scan and scan_charges > 0:
		_perform_coordinated_scan()

func _state_deploy_trap(delta: float) -> void:
	"""Deploy firewall at strategic position"""
	velocity = Vector2.ZERO
	_attempt_firewall_deployment()
	_transition_to_chase()

# ========================
# STATE TRANSITIONS
# ========================
func _transition_to_patrol() -> void:
	current_state = State.PATROL
	chase_target = null
	is_coordinating = false

func _transition_to_investigate() -> void:
	current_state = State.INVESTIGATE
	chase_target = null
	last_seen_timer = 0.0

func _transition_to_chase() -> void:
	current_state = State.CHASE
	is_coordinating = false

func _transition_to_coordinate() -> void:
	current_state = State.COORDINATE
	is_coordinating = true

# ========================
# SCANNING SYSTEMS
# ========================
func _perform_reactive_scan() -> void:
	"""Launch scan at current virus position"""
	if not can_scan or scan_charges <= 0 or not is_instance_valid(chase_target):
		return
	
	_launch_scan(chase_target.global_position, 1.0, ScanType.REACTIVE)

func _perform_predictive_scan() -> void:
	"""Launch scan at predicted virus position"""
	if not can_scan or scan_charges <= 0 or not is_instance_valid(chase_target):
		return
	
	# Predict virus movement
	var virus_velocity = chase_target.velocity
	var predicted_position = chase_target.global_position + (virus_velocity * scan_prediction_time)
	
	_launch_scan(predicted_position, 1.2, ScanType.PREDICTIVE)

func _perform_area_sweep() -> void:
	"""Launch large area scan"""
	if scan_charges <= 0:
		return
	
	_launch_scan(global_position, 2.0, ScanType.AREA_SWEEP)

func _perform_coordinated_scan() -> void:
	"""Synchronized scan with other antivirus"""
	if not can_scan or scan_charges <= 0 or not is_instance_valid(chase_target):
		return
	
	# All coordinating antivirus scan same position
	_launch_scan(chase_target.global_position, 1.5, ScanType.COORDINATED)
	
	# Signal other antivirus to scan
	for ally in nearby_antivirus:
		if ally.has_method("trigger_coordinated_scan"):
			ally.trigger_coordinated_scan(chase_target.global_position)

func trigger_coordinated_scan(_position: Vector2) -> void:
	"""Called by other antivirus to trigger coordinated scan"""
	if scan_charges > 0:
		_launch_scan(_position, 1.5, ScanType.COORDINATED)

func _launch_scan(_position: Vector2, scale_mult: float, _type: ScanType) -> void:
	"""Launch a scan with specified parameters"""
	if not scan_scene:
		return
	
	var scan := scan_scene.instantiate()
	scan.global_position = _position
	scan.scale *= scale_mult
	get_parent().add_child(scan)
	
	# Consume scan charge
	scan_charges -= 1
	can_scan = false
	scan_timer = 0.0
	
	# Visual/audio feedback
	EventBus.scan_launched.emit(_position, scan.scale)

# ========================
# FIREWALL DEPLOYMENT
# ========================
func _attempt_firewall_deployment() -> void:
	"""Deploy firewall at strategic position"""
	if not firewall_scene:
		return
	
	if firewall_cooldown_timer > 0.0:
		return
	
	if firewalls_deployed >= MAX_FIREWALLS:
		return
	
	# Calculate strategic position
	var firewall_position := _calculate_firewall_position()
	
	var firewall := firewall_scene.instantiate()
	firewall.global_position = firewall_position
	get_parent().add_child(firewall)
	
	firewalls_deployed += 1
	firewall_cooldown_timer = FIREWALL_COOLDOWN

func _calculate_firewall_position() -> Vector2:
	"""Calculate optimal firewall placement"""
	if not is_instance_valid(chase_target):
		return global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
	
	# Place firewall between antivirus and virus to cut off escape
	var direction := (chase_target.global_position - global_position).normalized()
	var distance := global_position.distance_to(chase_target.global_position)
	var placement_distance: Variant = min(distance * 0.6, 200.0)
	
	return global_position + direction * placement_distance

# ========================
# COORDINATION
# ========================
func _update_nearby_antivirus() -> void:
	"""Update list of nearby antivirus for coordination"""
	nearby_antivirus.clear()
	
	var all_antivirus := get_tree().get_nodes_in_group("antivirus")
	for av in all_antivirus:
		if av == self or not is_instance_valid(av):
			continue
		
		var distance := global_position.distance_to(av.global_position)
		if distance < coordination_radius:
			nearby_antivirus.append(av)

func _get_allies_positions() -> Array[Vector2]:
	"""Get positions of nearby allied antivirus"""
	var positions: Array[Vector2] = []
	for ally in nearby_antivirus:
		if is_instance_valid(ally):
			positions.append(ally.global_position)
	return positions

func _calculate_flanking_position(allies_positions: Array[Vector2]) -> Vector2:
	"""Calculate optimal flanking position"""
	if not is_instance_valid(chase_target):
		return global_position
	
	# Calculate average ally position
	var avg_position := Vector2.ZERO
	for pos in allies_positions:
		avg_position += pos
	if not allies_positions.is_empty():
		avg_position /= allies_positions.size()
	
	# Move to opposite side of virus from allies
	var to_virus := (chase_target.global_position - avg_position).normalized()
	var perpendicular := Vector2(-to_virus.y, to_virus.x)
	
	# Add some randomness
	var angle_offset := randf_range(-PI/4, PI/4)
	perpendicular = perpendicular.rotated(angle_offset)
	
	return chase_target.global_position + perpendicular * 150.0

# ========================
# TIMERS & UPDATES
# ========================
func _update_timers(delta: float) -> void:
	"""Update all cooldown timers"""
	# Scan recharge
	if scan_charges < 3:
		scan_recharge_timer += delta
		if scan_recharge_timer >= SCAN_RECHARGE_TIME:
			scan_charges += 1
			scan_recharge_timer = 0.0
	
	# Scan cooldown
	if not can_scan:
		scan_timer += delta
		if scan_timer >= scan_cooldown:
			can_scan = true
			scan_timer = 0.0
	
	# Firewall cooldown
	if firewall_cooldown_timer > 0.0:
		firewall_cooldown_timer -= delta

func _update_detection_radius() -> void:
	"""Update detection area based on virus discretion and threat level"""
	if is_instance_valid(GameManager.virus_node):
		var discretion_mult = GameManager.virus_node.discretion
		var threat_mult := 1.0
		
		match GameManager.get_threat_level():
			GameManager.ThreatLevel.MEDIUM:
				threat_mult = 1.3
			GameManager.ThreatLevel.CRITICAL:
				threat_mult = 1.6
		
		detection_area.scale = detection_radius * discretion_mult * threat_mult

func _update_visual_feedback() -> void:
	"""Update visual appearance based on state"""
	if not sprite:
		return
	
	match current_state:
		State.PATROL:
			sprite.modulate = Color(1, 0, 0, 1)
		State.INVESTIGATE:
			sprite.modulate = Color(1, 0.5, 0, 1)
		State.CHASE:
			sprite.modulate = Color(1, 0, 0, 1.5)
		State.COORDINATE:
			sprite.modulate = Color(1, 0, 1, 1)
		State.DEPLOY_TRAP:
			sprite.modulate = Color(0.5, 0, 1, 1)

# ========================
# DETECTION
# ========================
func _on_detection_body_entered(body: Node2D) -> void:
	"""Handle virus detection"""
	if body.is_in_group("virus") and not body.is_invisible:
		chase_target = body
		_transition_to_chase()
		EventBus.antivirus_detected_virus.emit(self, body)

func _on_detection_body_exited(body: Node2D) -> void:
	"""Handle virus leaving detection"""
	if body == chase_target:
		EventBus.antivirus_lost_virus.emit(self)
		last_known_virus_position = body.global_position
		_transition_to_investigate()

# ========================
# HELPERS
# ========================
func _pick_random_wander() -> void:
	"""Fallback wander behavior"""
	var random_direction := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	velocity = random_direction * base_speed * _get_speed_multiplier()

func slow_down(enable: bool) -> void:
	"""Apply or remove slowing effect"""
	if enable:
		base_speed *= 0.5
	else:
		base_speed *= 2.0

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

# ========================
# EVENT HANDLERS
# ========================
func _on_threat_level_changed(_old_level: GameManager.ThreatLevel, new_level: GameManager.ThreatLevel) -> void:
	"""React to threat level changes"""
	match new_level:
		GameManager.ThreatLevel.MEDIUM:
			predictive_scan_enabled = true
			scan_cooldown = 3.5
		GameManager.ThreatLevel.CRITICAL:
			predictive_scan_enabled = true
			scan_cooldown = 2.5
			trap_placement_enabled = true

func _on_virus_damaged(_amount: int, _remaining_health: int) -> void:
	"""React when virus takes damage"""
	# If virus is low on health, increase aggression
	if _remaining_health < 30:
		chase_speed_multiplier = 2.0

# ========================
# COLLISION
# ========================
func _on_body_entered(body: Node) -> void:
	"""Handle collision with virus"""
	if body.is_in_group("virus"):
		EventBus.emit_screen_shake(0.75, 0.2)
		body.take_damage(damage)
		queue_free()
