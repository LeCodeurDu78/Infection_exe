extends CharacterBody2D

## Main player character - the virus
## Handles movement, leveling, and infection capabilities

# ========================
# CONSTANTS
# ========================
const XP_LEVELS := [20, 40, 60, 80, 100]
const MAX_LEVEL := 5
const INVISIBLE_ALPHA := 0.4
const VISIBLE_ALPHA := 1.0

# ========================
# EXPORTS
# ========================
@export var base_speed := 400.0
@export var infection_rate := 1.0
@export var discretion := 1.0

# ========================
# STATE
# ========================
var current_level := 1
var xp := 0
var is_invisible := false

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
	move_and_slide()

# ========================
# MOVEMENT
# ========================
func _handle_movement() -> void:
	"""Handle player input and movement"""
	var input_direction := Input.get_vector(
		"ui_left", "ui_right",
		"ui_up", "ui_down"
	)
	
	velocity = input_direction * base_speed

# ========================
# LEVELING
# ========================
func add_xp(infected: Infectable, points: int) -> void:
	"""Add XP and check for level up"""
	xp += points
	EventBus.virus_xp_gained.emit(points, xp)
	
	while current_level < MAX_LEVEL and xp >= get_xp_for_next_level():
		_level_up()

func _level_up() -> void:
	"""Internal: Handle level up"""
	xp -= get_xp_for_next_level()
	current_level += 1
	
	EventBus.virus_leveled_up.emit(current_level)
	EventBus.emit_notification("Level Up! Level %d" % current_level, "success")
	EventBus.emit_screen_shake(0.5, 0.2)
	
	# Unlock new mutations
	if has_node("MutationManager"):
		$MutationManager.unlock_mutations()

func get_xp_for_next_level() -> int:
	"""Returns XP required for next level"""
	if current_level > XP_LEVELS.size():
		return XP_LEVELS[-1]
	return XP_LEVELS[current_level - 1]

# ========================
# ABILITIES
# ========================
func set_invisibility(visible: bool) -> void:
	"""Toggle invisibility state"""
	is_invisible = visible
	modulate.a = INVISIBLE_ALPHA if visible else VISIBLE_ALPHA

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
func _exit_tree() -> void:
	# Notify GameManager
	if GameManager:
		GameManager.on_virus_destroyed()