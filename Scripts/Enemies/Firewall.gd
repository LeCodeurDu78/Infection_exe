extends StaticBody2D
class_name Firewall

## Firewall - Barrier deployed by antivirus
## Blocks virus movement and deals damage on contact
## Temporary obstacle that forces virus to change path

# ========================
# EXPORTS
# ========================
@export var lifetime := 8.0  # Seconds before firewall expires
@export var damage_per_second := 10.0
@export var slow_multiplier := 0.3  # How much to slow virus (0.0 - 1.0)
@export var health := 100.0  # Can be destroyed by special mutations

# ========================
# CONSTANTS
# ========================
const WARNING_DURATION := 0.5  # Warning phase before activation
const FLASH_SPEED := 10.0

# ========================
# STATE
# ========================
var is_active := false
var lifetime_timer := 0.0
var virus_inside := false
var warning_timer := 0.0

# ========================
# VISUAL
# ========================
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var damage_area: Area2D = $DamageArea
@onready var particles: GPUParticles2D = $Particles

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	# Start with warning phase
	_start_warning_phase()
	
	# Connect damage area
	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_entered)
		damage_area.body_exited.connect(_on_damage_area_exited)
	
	# Visual setup
	modulate = Color(1, 0.5, 0, 0.5)  # Orange warning
	collision_shape.disabled = true  # No collision during warning

func _process(delta: float) -> void:
	if not is_active:
		_update_warning_phase(delta)
	else:
		_update_active_phase(delta)

# ========================
# WARNING PHASE
# ========================
func _start_warning_phase() -> void:
	"""Initialize warning phase before activation"""
	is_active = false
	warning_timer = 0.0
	
	# Warning particles
	if particles:
		particles.emitting = true

func _update_warning_phase(delta: float) -> void:
	"""Flash warning and then activate"""
	warning_timer += delta
	
	# Flash effect
	var flash: Variant = abs(sin(warning_timer * FLASH_SPEED))
	modulate = Color(1, 0.5 + flash * 0.5, 0, 0.5 + flash * 0.5)
	
	if warning_timer >= WARNING_DURATION:
		_activate()

# ========================
# ACTIVATION
# ========================
func _activate() -> void:
	"""Activate firewall - becomes solid"""
	is_active = true
	collision_shape.disabled = false
	modulate = Color(1, 0, 0, 0.9)
	
	EventBus.emit_screen_shake(0.3, 0.2)

# ========================
# ACTIVE PHASE
# ========================
func _update_active_phase(delta: float) -> void:
	"""Update active firewall"""
	lifetime_timer += delta
	
	# Apply damage to virus if inside
	if virus_inside:
		_damage_virus(delta)
	
	# Visual degradation over time
	var life_percent := 1.0 - (lifetime_timer / lifetime)
	modulate.a = 0.5 + (life_percent * 0.4)
	
	# Expire
	if lifetime_timer >= lifetime:
		_expire()

# ========================
# DAMAGE SYSTEM
# ========================
func _on_damage_area_entered(body: Node2D) -> void:
	"""Virus entered firewall area"""
	if body.is_in_group("virus"):
		virus_inside = true
		_apply_slow(body, true)

func _on_damage_area_exited(body: Node2D) -> void:
	"""Virus left firewall area"""
	if body.is_in_group("virus"):
		virus_inside = false
		_apply_slow(body, false)

func _damage_virus(delta: float) -> void:
	"""Deal damage over time to virus"""
	if not is_instance_valid(GameManager.virus_node):
		return
	
	var damage := int(damage_per_second * delta)
	if damage > 0:
		GameManager.virus_node.take_damage(damage)

func _apply_slow(virus: Node2D, enable: bool) -> void:
	"""Apply movement penalty to virus"""
	if not is_instance_valid(virus):
		return
	
	if enable:
		virus.base_speed *= slow_multiplier
		EventBus.emit_notification("⚠️ Ralenti par Firewall!", "warning")
	else:
		virus.base_speed /= slow_multiplier

# ========================
# DESTRUCTION
# ========================
func take_damage(amount: int) -> void:
	"""Firewall can be damaged by certain mutations"""
	health -= amount
	
	# Visual feedback
	sprite.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color(1, 0, 0, 0.9)
	
	if health <= 0:
		_destroy()

func _destroy() -> void:
	"""Firewall destroyed by virus"""
	EventBus.emit_notification("✨ Firewall Détruit!", "success")
	EventBus.emit_screen_shake(0.4, 0.2)
	queue_free()

func _expire() -> void:
	"""Firewall expired naturally"""
	# Fade out animation
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
