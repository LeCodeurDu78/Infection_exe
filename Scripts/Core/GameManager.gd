extends Node

## Autoload singleton for game state management
## Handles infection tracking, threat levels, and global game state
## Uses EventBus for global event communication

# ========================
# ENUMS
# ========================
enum ThreatLevel { LOW, MEDIUM, CRITICAL }

# ========================
# STATE
# ========================
var total_infectables := 0
var infected_count := 0
var _current_threat_level := ThreatLevel.LOW

# Virus reference (set by virus when ready)
var virus_node: Node2D = null

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	reset_game()

# ========================
# GAME STATE
# ========================
func reset_game() -> void:
	"""Reset all game state to initial values"""
	total_infectables = 0
	infected_count = 0
	_current_threat_level = ThreatLevel.LOW
	virus_node = null

# ========================
# INFECTION TRACKING
# ========================
func register_infectable() -> void:
	"""Called when a new infectable object is created"""
	total_infectables += 1

func on_target_infected(_position: Vector2, points: int) -> void:
	"""Called when an infectable object is successfully infected"""
	infected_count += 1
	EventBus.infection_completed.emit(_position, points)
	EventBus.data_collected.emit("infection", 1)
	_check_threat_level_change()
	_check_win_condition()

func get_infection_percent() -> float:
	"""Returns the percentage of infected targets (0-100)"""
	if total_infectables == 0:
		return 0.0
	return (float(infected_count) / float(total_infectables)) * 100.0

# ========================
# THREAT LEVEL
# ========================
func get_threat_level() -> ThreatLevel:
	"""Returns the current threat level based on infection percentage"""
	return _current_threat_level

func _check_threat_level_change() -> void:
	"""Internal: Check if threat level should change"""
	var new_level := _calculate_threat_level()
	if new_level != _current_threat_level:
		var old_level := _current_threat_level
		_current_threat_level = new_level
		EventBus.threat_level_changed.emit(old_level, new_level)
		EventBus.threat_level_warning.emit(new_level)

func _calculate_threat_level() -> ThreatLevel:
	"""Internal: Calculate threat level from infection percent"""
	var percent := get_infection_percent()
	if percent < 30.0:
		return ThreatLevel.LOW
	elif percent < 70.0:
		return ThreatLevel.MEDIUM
	else:
		return ThreatLevel.CRITICAL

# ========================
# WIN/LOSS CONDITIONS
# ========================
func _check_win_condition() -> void:
	"""Internal: Check if player has won"""
	if get_infection_percent() >= 100.0:
		EventBus.game_won.emit(100.0, 0.0)  # TODO: Add time tracking

func on_virus_destroyed() -> void:
	"""Called when the virus is destroyed"""
	EventBus.game_lost.emit("virus_destroyed")
	EventBus.virus_destroyed.emit()

# ========================
# VIRUS DATA (for UI)
# ========================
func get_virus_xp_text() -> String:
	"""Returns formatted XP text for UI display"""
	if not is_instance_valid(virus_node):
		return "0 / 0"
	return "%d / %d" % [virus_node.xp, virus_node.get_xp_for_next_level()]
