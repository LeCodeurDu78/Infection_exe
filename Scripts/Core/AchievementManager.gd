extends Node

## Achievement Manager
## Tracks and awards achievements/trophies
## Shows popups when unlocked

# ========================
# ACHIEVEMENT DATA CLASS
# ========================
class Achievement:
	var id: String
	var name: String
	var description: String
	var icon: String
	var unlocked: bool = false
	var progress: int = 0
	var target: int = 1
	var secret: bool = false
	var unlock_time: int = 0
	
	func _init(_id: String, _name: String, _desc: String, _icon: String = "🏆"):
		id = _id
		name = _name
		description = _desc
		icon = _icon

# ========================
# ACHIEVEMENTS
# ========================
var achievements: Dictionary = {}
var unlocked_count: int = 0
var total_count: int = 0

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	_initialize_achievements()
	_load_achievements()
	_connect_events()
	print("🏆 AchievementManager initialized")

func _initialize_achievements() -> void:
	"""Define all game achievements"""
	
	# ===== PROGRESSION =====
	_add_achievement(Achievement.new(
		"first_infection",
		"Premier Contact",
		"Infecter votre premier fichier",
		"🦠"
	))
	
	_add_achievement(Achievement.new(
		"level_5",
		"Évolution Complète",
		"Atteindre le niveau 5",
		"⬆️"
	))
	
	_add_achievement(Achievement.new(
		"all_zones",
		"Explorateur Système",
		"Compléter toutes les zones",
		"🗺️"
	))
	
	_add_achievement(Achievement.new(
		"core_zone",
		"Cœur du Système",
		"Atteindre le Noyau Système",
		"💎"
	))
	
	# ===== INFECTION =====
	var infect_100 := Achievement.new(
		"infect_100",
		"Épidémie",
		"Infecter 100 fichiers",
		"📁"
	)
	infect_100.target = 100
	_add_achievement(infect_100)
	
	var infect_500 := Achievement.new(
		"infect_500",
		"Pandémie",
		"Infecter 500 fichiers",
		"🌐"
	)
	infect_500.target = 500
	_add_achievement(infect_500)
	
	var perfect_zone := Achievement.new(
		"perfect_zone",
		"Infection Totale",
		"Infecter 100% d'une zone",
		"✨"
	)
	_add_achievement(perfect_zone)
	
	# ===== COMBAT =====
	var defeat_10_av := Achievement.new(
		"defeat_10_av",
		"Antivirus Killer",
		"Détruire 10 antivirus",
		"🛡️"
	)
	defeat_10_av.target = 10
	_add_achievement(defeat_10_av)
	
	var no_damage_zone := Achievement.new(
		"no_damage_zone",
		"Furtif",
		"Compléter une zone sans prendre de dégâts",
		"👻"
	)
	_add_achievement(no_damage_zone)
	
	var survive_critical := Achievement.new(
		"survive_critical",
		"Survivant",
		"Survivre 60 secondes en menace critique",
		"⚠️"
	)
	_add_achievement(survive_critical)
	
	# ===== MUTATIONS =====
	var unlock_all_mutations := Achievement.new(
		"unlock_all_mutations",
		"ADN Parfait",
		"Débloquer toutes les mutations",
		"🧬"
	)
	_add_achievement(unlock_all_mutations)
	
	var use_5_mutations := Achievement.new(
		"use_5_mutations",
		"Multi-Mutation",
		"Utiliser 5 mutations différentes en un run",
		"🔀"
	)
	use_5_mutations.target = 5
	_add_achievement(use_5_mutations)
	
	# ===== SPEED =====
	var speed_run := Achievement.new(
		"speed_run",
		"Vitesse Éclair",
		"Compléter une zone en moins de 2 minutes",
		"⚡"
	)
	_add_achievement(speed_run)
	
	var marathon := Achievement.new(
		"marathon",
		"Marathonien",
		"Jouer pendant 1 heure sans mourir",
		"🏃"
	)
	_add_achievement(marathon)
	
	# ===== SECRET =====
	var secret_1 := Achievement.new(
		"secret_glitch",
		"???",
		"Découvrez le glitch secret",
		"❓"
	)
	secret_1.secret = true
	_add_achievement(secret_1)
	
	var secret_2 := Achievement.new(
		"secret_developer",
		"???",
		"Trouvez le message du développeur",
		"💻"
	)
	secret_2.secret = true
	_add_achievement(secret_2)
	
	total_count = achievements.size()

func _add_achievement(achievement: Achievement) -> void:
	"""Add achievement to the collection"""
	achievements[achievement.id] = achievement

# ========================
# EVENT CONNECTIONS
# ========================
func _connect_events() -> void:
	"""Connect to EventBus signals"""
	
	# Infection events
	EventBus.infection_completed.connect(_on_infection_completed)
	EventBus.zone_completed.connect(_on_zone_completed)
	
	# Combat events
	EventBus.antivirus_destroyed.connect(_on_antivirus_destroyed)
	
	# Level events
	EventBus.virus_leveled_up.connect(_on_virus_leveled_up)
	
	# Zone events
	EventBus.zone_entered.connect(_on_zone_entered)

# ========================
# ACHIEVEMENT UNLOCK
# ========================
func unlock_achievement(achievement_id: String) -> bool:
	"""Unlock an achievement"""
	if achievement_id not in achievements:
		push_warning("AchievementManager: Unknown achievement '%s'" % achievement_id)
		return false
	
	var achievement: Achievement = achievements[achievement_id]
	
	if achievement.unlocked:
		return false  # Already unlocked
	
	# Unlock it
	achievement.unlocked = true
	achievement.unlock_time = int(Time.get_unix_time_from_system())
	unlocked_count += 1
	
	# Show popup
	_show_achievement_popup(achievement)
	
	# Emit event
	EventBus.achievement_unlocked.emit(achievement.name)
	
	# Play sound
	#if AudioManager:
	#	AudioManager.play_sfx("achievement_unlock")
	
	# Save
	_save_achievements()
	
	print("🏆 Achievement unlocked: %s" % achievement.name)
	return true

func add_progress(achievement_id: String, amount: int = 1) -> void:
	"""Add progress to an achievement"""
	if achievement_id not in achievements:
		return
	
	var achievement: Achievement = achievements[achievement_id]
	
	if achievement.unlocked:
		return  # Already unlocked
	
	achievement.progress += amount
	
	# Check if completed
	if achievement.progress >= achievement.target:
		unlock_achievement(achievement_id)

func _show_achievement_popup(achievement: Achievement) -> void:
	"""Show achievement unlock popup"""
	var message := "%s %s" % [achievement.icon, achievement.name]
	EventBus.emit_notification(message, "success")
	
	# Could show a fancier popup with description
	# For now using the notification system

# ========================
# EVENT HANDLERS
# ========================
func _on_infection_completed(_infectable: Variant, _points: int) -> void:
	"""Track infection achievements"""
	add_progress("infect_100")
	add_progress("infect_500")
	
	# First infection
	if achievements["first_infection"].progress == 0:
		unlock_achievement("first_infection")

func _on_zone_completed(_zone_name: String, infection_percent: float) -> void:
	"""Track zone achievements"""
	if infection_percent >= 100.0:
		unlock_achievement("perfect_zone")
	
	# Check if all zones completed
	if ZoneManager:
		if ZoneManager.get_completion_percent() >= 100.0:
			unlock_achievement("all_zones")

func _on_antivirus_destroyed(_antivirus: Node2D) -> void:
	"""Track antivirus destruction"""
	add_progress("defeat_10_av")

func _on_virus_leveled_up(level: int) -> void:
	"""Track level achievements"""
	if level >= 5:
		unlock_achievement("level_5")

func _on_zone_entered(_zone_name: String) -> void:
	"""Track zone entry"""
	if ZoneManager:
		var current_zone = ZoneManager.get_current_zone()
		if current_zone and current_zone.id == "core":
			unlock_achievement("core_zone")

# ========================
# MANUAL TRIGGERS
# ========================
func check_speed_run(zone_time: float) -> void:
	"""Check if speed run achievement earned"""
	if zone_time < 120.0:  # 2 minutes
		unlock_achievement("speed_run")

func check_no_damage(took_damage: bool) -> void:
	"""Check if no damage achievement earned"""
	if not took_damage:
		unlock_achievement("no_damage_zone")

func check_marathon(play_time: float) -> void:
	"""Check marathon achievement"""
	if play_time >= 3600.0:  # 1 hour
		unlock_achievement("marathon")

func check_mutations_used(mutations_used: Array) -> void:
	"""Check multi-mutation achievement"""
	if mutations_used.size() >= 5:
		unlock_achievement("use_5_mutations")

func check_all_mutations_unlocked(total_unlocked: int, total_mutations: int) -> void:
	"""Check if all mutations unlocked"""
	if total_unlocked >= total_mutations:
		unlock_achievement("unlock_all_mutations")

# ========================
# QUERIES
# ========================
func is_unlocked(achievement_id: String) -> bool:
	"""Check if achievement is unlocked"""
	if achievement_id not in achievements:
		return false
	return achievements[achievement_id].unlocked

func get_achievement(achievement_id: String) -> Achievement:
	"""Get achievement data"""
	if achievement_id in achievements:
		return achievements[achievement_id]
	return null

func get_all_achievements() -> Array[Achievement]:
	"""Get all achievements"""
	var all: Array[Achievement] = []
	for ach_id in achievements:
		all.append(achievements[ach_id])
	return all

func get_unlocked_achievements() -> Array[Achievement]:
	"""Get only unlocked achievements"""
	var unlocked: Array[Achievement] = []
	for ach_id in achievements:
		if achievements[ach_id].unlocked:
			unlocked.append(achievements[ach_id])
	return unlocked

func get_completion_percent() -> float:
	"""Get achievement completion percentage"""
	if total_count == 0:
		return 0.0
	return (float(unlocked_count) / float(total_count)) * 100.0

func get_stats() -> Dictionary:
	"""Get achievement statistics"""
	return {
		"total": total_count,
		"unlocked": unlocked_count,
		"locked": total_count - unlocked_count,
		"completion_percent": get_completion_percent()
	}

# ========================
# SAVE/LOAD
# ========================
func _save_achievements() -> void:
	"""Save achievements to SaveManager"""
	if not SaveManager:
		return
	
	var save_data := {}
	
	for ach_id in achievements:
		var ach: Achievement = achievements[ach_id]
		save_data[ach_id] = {
			"unlocked": ach.unlocked,
			"progress": ach.progress,
			"unlock_time": ach.unlock_time
		}
	
	SaveManager.data["achievements"] = save_data
	SaveManager.save_data()

func _load_achievements() -> void:
	"""Load achievements from SaveManager"""
	if not SaveManager:
		return
	
	if "achievements" not in SaveManager.data:
		return
	
	var save_data: Dictionary = SaveManager.data.achievements
	
	unlocked_count = 0
	
	for ach_id in save_data:
		if ach_id not in achievements:
			continue
		
		var ach: Achievement = achievements[ach_id]
		var ach_data: Dictionary = save_data[ach_id]
		
		if "unlocked" in ach_data:
			ach.unlocked = ach_data.unlocked
			if ach.unlocked:
				unlocked_count += 1
		
		if "progress" in ach_data:
			ach.progress = ach_data.progress
		
		if "unlock_time" in ach_data:
			ach.unlock_time = ach_data.unlock_time

# ========================
# UTILITY
# ========================
func reset_achievements() -> void:
	"""Reset all achievements (for testing)"""
	for ach_id in achievements:
		var ach: Achievement = achievements[ach_id]
		ach.unlocked = false
		ach.progress = 0
		ach.unlock_time = 0
	
	unlocked_count = 0
	_save_achievements()
	
func unlock_all_achievements() -> void:
	"""Unlock all achievements (for testing)"""
	for ach_id in achievements:
		unlock_achievement(ach_id)
