extends Mutation
class_name ViralShieldMutation

## Viral Shield - Absorbs damage for a limited time
## Creates an invulnerability shield that blocks all damage

# ========================
# EXPORTS
# ========================
@export var shield_duration := 5.0
@export var cooldown := 25.0
@export var shield_health := 100  # Amount of damage shield can absorb

# ========================
# STATE
# ========================
var is_active := false
var is_on_cooldown := false
var active_timer := 0.0
var cooldown_timer := 0.0
var current_shield_health := 0

# ========================
# ACTIVATION
# ========================
func apply(virus: Node2D) -> void:
	if is_on_cooldown or is_active:
		return
	
	is_active = true
	active_timer = shield_duration
	current_shield_health = shield_health
	
	# Enable shield on virus
	virus.set("shield_active", true)
	virus.set("shield_health", current_shield_health)
	
	# Visual feedback
	_activate_shield_visuals(virus)
	
	EventBus.mutation_activated.emit(self)

# ========================
# UPDATE
# ========================
func process(virus: Node2D, delta: float) -> void:
	if is_active:
		active_timer -= delta
		if active_timer <= 0:
			_deactivate_shield(virus)
	
	if is_on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			is_on_cooldown = false
			EventBus.mutation_cooldown_finished.emit(name)

# ========================
# SHIELD MANAGEMENT
# ========================
func _activate_shield_visuals(virus: Node2D) -> void:
	
	virus.get_node('ViralShield').visible = true
		
		# Restore color when shield ends
	await virus.get_tree().create_timer(shield_duration).timeout

	virus.get_node('ViralShield').visible = false

func _deactivate_shield(virus: Node2D) -> void:
	is_active = false
	is_on_cooldown = true
	cooldown_timer = cooldown
	current_shield_health = 0
	
	# Disable shield on virus
	virus.set("shield_active", false)
	virus.set("shield_health", 0)
	
	virus.get_node('ViralShield').visible = false
	EventBus.mutation_cooldown_started.emit(name, cooldown)

# Called by virus when taking damage
func absorb_damage(damage: int) -> int:
	if not is_active:
		return damage
	
	var absorbed = min(damage, current_shield_health)
	current_shield_health -= absorbed
	var remaining_damage = damage - absorbed
	
	return remaining_damage

# ========================
# COOLDOWN INFO
# ========================
func get_cooldown() -> float:
	return cooldown_timer if is_on_cooldown else 0.0

func get_max_cooldown() -> float:
	return cooldown