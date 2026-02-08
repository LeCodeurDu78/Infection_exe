extends Area2D
class_name Infectable

## Represents an object that can be infected by the virus
## Handles infection timing and state

# ========================
# EXPORTS
# ========================
@export var points_worth := 10
@export var infection_time := 0.75

# ========================
# STATE
# ========================
var is_infected := false
var is_virus_in_range := false
var infection_timer: Timer = null

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	# Register with GameManager
	GameManager.register_infectable()

# ========================
# INFECTION
# ========================
func start_infection(virus_infection_rate: float) -> void:
	"""Begin the infection process"""
	if is_infected or infection_timer != null:
		return
	
	EventBus.infection_started.emit(self, points_worth)
	
	# Create and configure timer
	infection_timer = Timer.new()
	infection_timer.wait_time = infection_time / virus_infection_rate
	infection_timer.one_shot = true
	infection_timer.timeout.connect(_on_infection_complete)
	add_child(infection_timer)
	infection_timer.start()

func _on_infection_complete() -> void:
	"""Called when infection timer completes"""
	# Only infect if virus is still in range
	if is_virus_in_range and not is_infected:
		_complete_infection()
	
	# Cleanup timer
	if infection_timer:
		infection_timer.queue_free()
		infection_timer = null

func _complete_infection() -> void:
	"""Mark object as infected and notify game"""
	if is_infected:
		return
	
	is_infected = true
	EventBus.emit_screen_shake(0.25, 0.2)
	GameManager.on_target_infected(position, points_worth)
	
	# Visual feedback or destruction
	queue_free()

func cancel_infection() -> void:
	"""Cancel ongoing infection"""
	if infection_timer:
		EventBus.infection_cancelled.emit(self)
		infection_timer.stop()
		infection_timer.queue_free()
		infection_timer = null

# ========================
# DETECTION
# ========================
func _on_area_entered(area: Area2D) -> void:
	"""Virus infection zone entered"""
	if area.is_in_group("virus_infection_zone"):
		is_virus_in_range = true
		var virus = area.get_parent()
		if virus and virus.has_method("get"):
			start_infection(virus.infection_rate)

func _on_area_exited(area: Area2D) -> void:
	"""Virus infection zone exited"""
	if area.is_in_group("virus_infection_zone"):
		is_virus_in_range = false
		cancel_infection()