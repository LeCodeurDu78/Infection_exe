extends CharacterBody2D

## Main player character - the virus
## Handles movement, leveling, and infection capabilities

# ========================
# CONSTANTS
# ========================
@export var XP_LEVELS := [20, 50, 100, 200, 400, 800, 1500, 3000, 5000, 10000,
						 20000, 40000, 80000, 150000, 300000, 500000, 1000000,
						 2000000, 4000000] # XP required for each level up to MAX_LEVEL
@export var MAX_LEVEL := 20

# ========================
# EXPORTS
# ========================
@export var max_health := 100.0
@export var base_speed := 400.0
@export var infection_rate := 1.0
@export var discretion := 1.0
@export var xp_multiplier := 1.0

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

var invulnerable := false
@onready var infection_zone := $InfectionZone

var shield_active := false
var shield_health := 0

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

	if invulnerable:
		current_health = 999999.9
		EventBus.virus_healed.emit(current_health, current_health)
	
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
	xp += int(points * xp_multiplier) 
	EventBus.virus_xp_gained.emit(points, xp)
	
	while current_level < MAX_LEVEL and xp >= get_xp_for_next_level():
		_level_up()

func _level_up() -> void:
	"""Internal: Handle level up"""
	xp -= get_xp_for_next_level()
	current_level += 1
	
	# Unlock new mutations
	$MutationManager.unlock_mutations()

	EventBus.virus_leveled_up.emit(current_level)
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
	var actual_damage = amount

	# Check if shield is active
	if shield_active and has_node("MutationManager"):
		var mutation_manager = get_node("MutationManager")
		for mutation in mutation_manager.active_mutations:
			if mutation is ViralShieldMutation:
				actual_damage = mutation.absorb_damage(amount)
				break
	
	if actual_damage <= 0:
		return  # All damage absorbed

	current_health -= actual_damage
	EventBus.virus_damaged.emit(actual_damage, current_health)
	if current_health <= 0:
		var is_reboot = false

		for mutation in $MutationManager.active_mutations:
			if mutation.name == "Reboot":
				$MutationManager.remove_mutation(mutation)
				is_reboot = true

		if not is_reboot:
			EventBus.virus_destroyed.emit(self)
			queue_free()
		else:
			current_health = max_health * 0.5
			EventBus.virus_healed.emit(max_health * 0.5, current_health)
