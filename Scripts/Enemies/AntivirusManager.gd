extends Node
class_name AntivirusManager

## Manages spawning and despawning of antivirus enemies
## Responds to threat level changes

# ========================
# EXPORTS
# ========================
@export var antivirus_scene: PackedScene
@export var spawn_points: Array[Node2D] = []
@export var base_count := 2
@export var max_count := 5

# ========================
# STATE
# ========================
var active_antiviruses: Array[Node] = []

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	# Connect to EventBus
	EventBus.threat_level_changed.connect(_on_threat_level_changed)
	EventBus.spawn_antivirus.connect(_spawn_antivirus)
	
	# Initial spawn
	_update_antivirus_count()

# ========================
# SPAWNING
# ========================
func _update_antivirus_count() -> void:
	"""Update number of active antiviruses based on threat level"""
	var target_count := _get_target_count()
	
	# Spawn more if needed
	while active_antiviruses.size() < target_count:
		_spawn_antivirus(1)
	
	# Remove excess if needed
	while active_antiviruses.size() > target_count:
		_remove_antivirus()

func _spawn_antivirus(count: int) -> void:
	"""Spawn a single antivirus at random spawn point"""
	if not antivirus_scene or spawn_points.is_empty():
		push_warning("AntivirusManager: Cannot spawn - missing scene or spawn points")
		return
	
	for i in range(count):
		var antivirus := antivirus_scene.instantiate()
		var spawn_point: Variant = spawn_points.pick_random()
		antivirus.global_position = spawn_point.global_position
		
		add_child(antivirus)
		active_antiviruses.append(antivirus)
	
		EventBus.antivirus_spawned.emit(antivirus, spawn_point.global_position)

func _remove_antivirus() -> void:
	"""Remove one antivirus from the scene"""
	if active_antiviruses.is_empty():
		return
	
	var antivirus: Variant = active_antiviruses.pop_back()
	if is_instance_valid(antivirus):
		EventBus.antivirus_despawned.emit(antivirus)
		antivirus.queue_free()

# ========================
# DIFFICULTY
# ========================
func _get_target_count() -> int:
	"""Calculate how many antiviruses should be active"""
	match GameManager.get_threat_level():
		GameManager.ThreatLevel.LOW:
			return base_count
		GameManager.ThreatLevel.MEDIUM:
			return base_count + 1
		GameManager.ThreatLevel.CRITICAL:
			return max_count
	return base_count

func _on_threat_level_changed(_old_level: GameManager.ThreatLevel, _new_level: GameManager.ThreatLevel) -> void:
	"""React to threat level changes"""
	_update_antivirus_count()
