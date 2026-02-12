extends Node

## Zone Manager
## Manages game zones/levels progression (Dead Cells style)
## Handles zone unlocking, transitions, and completion tracking

# ========================
# ZONE DATA CLASS
# ========================
class Zone:
	var id: String
	var name: String
	var difficulty: int
	var scene_path: String
	var description: String
	var unlocked: bool = false
	var completed: bool = false
	var next_zones: Array[String] = []
	var required_infections: int = 0
	var threat_multiplier: float = 1.0
	var xp_multiplier: float = 1.0
	
	func _init(_id: String, _name: String, _difficulty: int, _scene: String, _desc: String):
		id = _id
		name = _name
		difficulty = _difficulty
		scene_path = _scene
		description = _desc

# ========================
# ZONES CONFIGURATION
# ========================
var zones: Dictionary = {}
var current_zone_id: String = ""
var zones_completed: Array[String] = []

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	_initialize_zones()
	_load_progression()
	print("🗺️ ZoneManager initialized")

func _initialize_zones() -> void:
	"""Initialize all game zones"""
	
	# FILES ZONE (Starting zone)
	var files_zone := Zone.new(
		"files",
		"Zone Fichiers",
		1,
		"res://Scenes/Zones/FilesZone.tscn",
		"Zone de départ. Fichiers basiques, peu de défense."
	)
	files_zone.unlocked = true
	files_zone.next_zones = ["processes", "network"]
	files_zone.required_infections = 15
	files_zone.threat_multiplier = 0.8
	files_zone.xp_multiplier = 1.0
	zones["files"] = files_zone
	
	# PROCESSES ZONE
	var processes_zone := Zone.new(
		"processes",
		"Zone Processus",
		2,
		"res://Scenes/Zones/ProcessesZone.tscn",
		"Processus actifs. Éléments mobiles, scans fréquents."
	)
	processes_zone.next_zones = ["network", "admin"]
	processes_zone.required_infections = 20
	processes_zone.threat_multiplier = 1.0
	processes_zone.xp_multiplier = 1.2
	zones["processes"] = processes_zone
	
	# NETWORK ZONE
	var network_zone := Zone.new(
		"network",
		"Zone Réseau",
		3,
		"res://Scenes/Zones/NetworkZone.tscn",
		"Infrastructure réseau. Firewalls, propagation en chaîne."
	)
	network_zone.next_zones = ["admin"]
	network_zone.required_infections = 25
	network_zone.threat_multiplier = 1.2
	network_zone.xp_multiplier = 1.5
	zones["network"] = network_zone
	
	# ADMIN ZONE
	var admin_zone := Zone.new(
		"admin",
		"Zone Admin",
		4,
		"res://Scenes/Zones/AdminZone.tscn",
		"Zone administrative. Meilleures mutations, surveillance max."
	)
	admin_zone.next_zones = ["core"]
	admin_zone.required_infections = 30
	admin_zone.threat_multiplier = 1.5
	admin_zone.xp_multiplier = 2.0
	zones["admin"] = admin_zone
	
	# CORE ZONE (Final)
	var core_zone := Zone.new(
		"core",
		"Noyau Système",
		5,
		"res://Scenes/Zones/CoreZone.tscn",
		"Zone finale. Boss fight. Victoire ou défaite."
	)
	core_zone.next_zones = []
	core_zone.required_infections = 50
	core_zone.threat_multiplier = 2.0
	core_zone.xp_multiplier = 3.0
	zones["core"] = core_zone

# ========================
# ZONE PROGRESSION
# ========================
func start_zone(zone_id: String) -> bool:
	"""Start a specific zone"""
	if zone_id not in zones:
		push_error("ZoneManager: Unknown zone '%s'" % zone_id)
		return false
	
	var zone: Zone = zones[zone_id]
	
	if not zone.unlocked:
		return false
	
	current_zone_id = zone_id
	
	# Apply zone modifiers
	_apply_zone_modifiers(zone)
	
	# Emit events
	EventBus.zone_entered.emit(zone.name)
	
	# Load zone scene
	get_tree().change_scene_to_file(zone.scene_path)
	
	return true

func complete_zone(zone_id: String, infection_percent: float) -> void:
	"""Mark a zone as completed"""
	if zone_id not in zones:
		return
	
	var zone: Zone = zones[zone_id]
	
	# Check if already completed
	if zone_id in zones_completed:
		return
	
	# Mark as completed
	zone.completed = true
	zones_completed.append(zone_id)
	
	# Unlock next zones
	for next_zone_id in zone.next_zones:
		if next_zone_id in zones:
			zones[next_zone_id].unlocked = true
	
	# Emit completion event
	EventBus.zone_completed.emit(zone.name, infection_percent)
	
	# Save progression
	_save_progression()

func _apply_zone_modifiers(_zone: Zone) -> void:
	"""Apply zone-specific modifiers to game"""
	# These would be read by other systems
	# For example, AntivirusManager could check current zone's threat_multiplier
	pass

# ========================
# ZONE QUERIES
# ========================
func get_current_zone() -> Zone:
	"""Get current zone data"""
	if current_zone_id in zones:
		return zones[current_zone_id]
	return null

func get_zone(zone_id: String) -> Zone:
	"""Get specific zone data"""
	if zone_id in zones:
		return zones[zone_id]
	return null

func is_zone_unlocked(zone_id: String) -> bool:
	"""Check if zone is unlocked"""
	if zone_id not in zones:
		return false
	return zones[zone_id].unlocked

func is_zone_completed(zone_id: String) -> bool:
	"""Check if zone is completed"""
	return zone_id in zones_completed

func get_unlocked_zones() -> Array[String]:
	"""Get list of unlocked zone IDs"""
	var unlocked: Array[String] = []
	for zone_id in zones:
		if zones[zone_id].unlocked:
			unlocked.append(zone_id)
	return unlocked

func get_available_next_zones() -> Array[String]:
	"""Get zones available from current zone"""
	var current := get_current_zone()
	if not current:
		return []
	
	var available: Array[String] = []
	for zone_id in current.next_zones:
		if zones[zone_id].unlocked:
			available.append(zone_id)
	
	return available

func get_completion_percent() -> float:
	"""Get overall zone completion percentage"""
	if zones.is_empty():
		return 0.0
	return (float(zones_completed.size()) / float(zones.size())) * 100.0

# ========================
# SAVE/LOAD
# ========================
func _save_progression() -> void:
	"""Save zone progression to SaveManager"""
	if not SaveManager:
		return
	
	var save_data := {
		"current_zone": current_zone_id,
		"zones_completed": zones_completed,
		"unlocked_zones": []
	}
	
	# Save which zones are unlocked
	for zone_id in zones:
		if zones[zone_id].unlocked:
			save_data.unlocked_zones.append(zone_id)
	
	SaveManager.data["zone_progression"] = save_data
	SaveManager.save_data()

func _load_progression() -> void:
	"""Load zone progression from SaveManager"""
	if not SaveManager:
		return
	
	if "zone_progression" not in SaveManager.data:
		return
	
	var save_data: Dictionary = SaveManager.data.zone_progression
	
	# Load current zone
	if "current_zone" in save_data:
		current_zone_id = save_data.current_zone
	
	# Load completed zones
	if "zones_completed" in save_data:
		zones_completed = save_data.zones_completed
		for zone_id in zones_completed:
			if zone_id in zones:
				zones[zone_id].completed = true
	
	# Load unlocked zones
	if "unlocked_zones" in save_data:
		for zone_id in save_data.unlocked_zones:
			if zone_id in zones:
				zones[zone_id].unlocked = true

# ========================
# ZONE SELECTION UI
# ========================
func show_zone_selection() -> void:
	"""Show zone selection screen (would load a UI scene)"""
	# This would load a zone selection scene
	# For now, just emit an event
	pass

# ========================
# UTILITY
# ========================
func reset_progression() -> void:
	"""Reset all zone progression (for testing)"""
	current_zone_id = ""
	zones_completed.clear()
	
	for zone_id in zones:
		zones[zone_id].unlocked = false
		zones[zone_id].completed = false
	
	# Unlock starting zone
	zones["files"].unlocked = true
	
	_save_progression()
	

func get_zone_stats() -> Dictionary:
	"""Get statistics about zones"""
	return {
		"total_zones": zones.size(),
		"unlocked_zones": get_unlocked_zones().size(),
		"completed_zones": zones_completed.size(),
		"completion_percent": get_completion_percent(),
		"current_zone": current_zone_id
	}
