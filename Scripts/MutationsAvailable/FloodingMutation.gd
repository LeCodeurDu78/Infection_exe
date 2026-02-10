extends Mutation
class_name FloodingMutation

## Flooding Mutation
## Temporarily slows down antivirus 

# ========================
# EXPORTS
# ========================
@export var active_duration: float = 4.0
@export var cooldown_duration: float = 20.0

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
	"""Activate slowing effect on antivirus"""
	if is_on_cooldown or is_active:
		return
	
	is_active = true
	remaining_active_time = active_duration
	
	var antivirus_nodes = virus.get_tree().get_nodes_in_group("antivirus")
	for node in antivirus_nodes:
		node.slow_down(true)  # Apply slowing effect

# ========================
# UPDATE
# ========================
func process(virus: Node2D, delta: float) -> void:
	"""Update slowing effect and cooldown timers"""
	if is_active:
		_update_active(virus, delta)
	elif is_on_cooldown:
		_update_cooldown(delta)

func _update_active(virus: Node2D, delta: float) -> void:
	"""Update active slowing timer"""
	remaining_active_time -= delta
	if remaining_active_time <= 0.0:
		_end_slowing(virus)

func _update_cooldown(delta: float) -> void:
	"""Update cooldown timer"""
	remaining_cooldown_time -= delta
	if remaining_cooldown_time <= 0.0:
		is_on_cooldown = false
		EventBus.mutation_cooldown_finished.emit("Flooding")

func _end_slowing(virus: Node2D) -> void:
	"""End slowing effect and start cooldown"""
	is_active = false
	is_on_cooldown = true
	remaining_cooldown_time = cooldown_duration
	
	var antivirus_nodes = virus.get_tree().get_nodes_in_group("antivirus")
	for node in antivirus_nodes:
		node.slow_down(false)  # Revert slowing effect

	EventBus.mutation_cooldown_started.emit("Flooding", cooldown_duration)

# ========================
# COOLDOWN INFO (for UI)
# ========================
func get_cooldown() -> float:
	"""Returns current cooldown time"""
	return remaining_cooldown_time if is_on_cooldown else 0.0

func get_max_cooldown() -> float:
	"""Returns maximum cooldown time"""
	return cooldown_duration