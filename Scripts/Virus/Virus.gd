extends CharacterBody2D

## Main player character - the virus
## Handles movement, leveling, and infection capabilities

# ========================
# CONSTANTS
# ========================
const XP_LEVELS := [20, 40, 60, 80, 100]
const MAX_LEVEL := 5

# ========================
# EXPORTS
# ========================
@export var max_health := 100
@export var base_speed := 400.0
@export var infection_rate := 1.0
@export var discretion := 1.0
@export var max_lenght_trail := 20

# ========================
# STATE
# ========================
var current_level := 1
var xp := 0
var is_invisible := false
var current_health := max_health

# Dash state
var is_dashing := false
var dash_velocity := Vector2.ZERO

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	# Register with GameManager
	GameManager.virus_node = self
	add_to_group("virus")
	
	# Notify spawn
	EventBus.virus_spawned.emit(self)
	EventBus.infection_completed.connect(add_xp)

func _physics_process(_delta: float) -> void:
	if is_dashing:
		velocity = dash_velocity
		move_and_slide()
		return
	
	_handle_movement()

	if Input.is_action_just_pressed("pause"):
		EventBus.pause_menu.emit()

	move_and_slide()

# ========================
# MOVEMENT
# ========================
func _handle_movement() -> void:
	"""Handle player input and movement"""
	var input_direction := Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)
	
	velocity = input_direction * base_speed

# ========================
# LEVELING
# ========================
func add_xp(_position: Vector2, points: int) -> void:
	"""Add XP and check for level up"""
	xp += points
	EventBus.virus_xp_gained.emit(points, xp)
	
	while current_level < MAX_LEVEL and xp >= get_xp_for_next_level():
		_level_up()

func _level_up() -> void:
	"""Internal: Handle level up"""
	xp -= get_xp_for_next_level()
	current_level += 1
	
	# Unlock new mutations
	if has_node("MutationManager"):
		$MutationManager.unlock_mutations()

	EventBus.virus_leveled_up.emit(current_level)
	EventBus.emit_notification("Level Up! Level %d" % current_level, "success")
	EventBus.emit_screen_shake(0.5, 0.2)

func get_xp_for_next_level() -> int:
	"""Returns XP required for next level"""
	if current_level > XP_LEVELS.size():
		return XP_LEVELS[-1]
	return XP_LEVELS[current_level - 1]

# ========================
# ABILITIES
# ========================
func set_invisibility(_visible: bool) -> void:
	"""Toggle invisibility state"""
	is_invisible = _visible
	get_node("GlowController").set_stealth_mode(is_invisible)

func start_dash(speed: float, direction: Vector2) -> void:
	"""Activate dash ability"""
	is_dashing = true
	dash_velocity = direction.normalized() * speed

func stop_dash() -> void:
	"""Deactivate dash ability"""
	is_dashing = false
	dash_velocity = Vector2.ZERO

# ========================
# CLEANUP
# ========================
func take_damage(amount: int) -> void:
	"""Handle taking damage from antivirus"""
	current_health -= amount
	EventBus.virus_damaged.emit(amount, current_health)
	if current_health <= 0:
		EventBus.virus_destroyed.emit(self)
		queue_free()

	# Optional: Add visual feedback for damage here (e.g., flash red, play sound, etc.)
