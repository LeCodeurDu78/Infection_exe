extends Mutation

## Invisibility Mutation
## Temporarily makes the virus invisible to antivirus

# ========================
# EXPORTS
# ========================
@export var active_duration := 5.0
@export var cooldown_duration := 20.0

# ========================
# STATE
# ========================
var remaining_active_time := 0.0
var remaining_cooldown_time := 0.0
var is_active := false
var is_on_cooldown := false

# ========================
# ACTIVATION
# ========================
func apply(virus: Node2D) -> void:
	"""Activate invisibility"""
	if is_on_cooldown or is_active:
		return
	
	is_active = true
	remaining_active_time = active_duration
	virus.set_invisibility(true)

# ========================
# UPDATE
# ========================
func process(virus: Node2D, delta: float) -> void:
	"""Update invisibility and cooldown timers"""
	if is_active:
		_update_active(virus, delta)
	elif is_on_cooldown:
		_update_cooldown(delta)

func _update_active(virus: Node2D, delta: float) -> void:
	"""Update active invisibility timer"""
	remaining_active_time -= delta
	if remaining_active_time <= 0.0:
		_end_invisibility(virus)

func _update_cooldown(delta: float) -> void:
	"""Update cooldown timer"""
	remaining_cooldown_time -= delta
	if remaining_cooldown_time <= 0.0:
		is_on_cooldown = false

func _end_invisibility(virus: Node2D) -> void:
	"""End invisibility and start cooldown"""
	is_active = false
	is_on_cooldown = true
	remaining_cooldown_time = cooldown_duration
	virus.set_invisibility(false)

# ========================
# COOLDOWN INFO (for UI)
# ========================
func get_cooldown() -> float:
	"""Returns current cooldown time"""
	return remaining_cooldown_time if is_on_cooldown else 0.0

func get_max_cooldown() -> float:
	"""Returns maximum cooldown time"""
	return cooldown_duration