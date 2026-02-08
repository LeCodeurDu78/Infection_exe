extends Node

#Disable warnings for empty signals since some events may not require parameters
## EventBus - Global Event System
## Centralized event management for decoupled communication
## Use this instead of direct function calls between unrelated systems

# ========================
# INFECTION EVENTS
# ========================
signal infection_started(target: Node, points: int)
signal infection_completed(position: Vector2, points: int)
signal infection_cancelled(target: Node)

# ========================
# VIRUS EVENTS
# ========================
signal virus_spawned(virus: Node2D)
signal virus_moved(position: Vector2)
signal virus_xp_gained(amount: int, total_xp: int)
signal virus_leveled_up(new_level: int)
signal virus_damaged(amount: int, remaining_health: int)
signal virus_healed(amount: int, current_health: int)
signal virus_destroyed

# ========================
# MUTATION EVENTS
# ========================
signal mutation_unlocked(mutation: Mutation)
signal mutation_activated(mutation: Mutation)
signal mutation_deactivated(mutation: Mutation)
signal mutation_ui_opened(mutations: Array)
signal mutation_ui_closed(selected_mutation: Mutation)
signal mutation_ability_used(mutation_name: String)
signal mutation_cooldown_started(mutation_name: String, duration: float)
signal mutation_cooldown_finished(mutation_name: String)

# ========================
# ANTIVIRUS EVENTS
# ========================
signal antivirus_spawned(antivirus: Node2D, position: Vector2)
signal antivirus_despawned(antivirus: Node2D)
signal antivirus_detected_virus(antivirus: Node2D, virus: Node2D)
signal antivirus_lost_virus(antivirus: Node2D)
signal scan_launched(position: Vector2, scale: Vector2)
signal scan_started(scan: Node2D)
signal scan_completed(scan: Node2D, cleaned_count: int)

# ========================
# THREAT LEVEL EVENTS
# ========================
signal threat_level_changed(old_level: GameManager.ThreatLevel, new_level: GameManager.ThreatLevel)
signal threat_level_warning(level: GameManager.ThreatLevel)

# ========================
# GAME STATE EVENTS
# ========================
signal start_menu
signal pause_menu
signal game_started
signal game_paused
signal game_resumed
signal game_won(infection_percent: float, time_elapsed: float)
signal game_lost(reason: String)
signal game_reset

# ========================
# ZONE EVENTS
# ========================
signal zone_entered(zone_name: String)
signal zone_completed(zone_name: String, completion_percent: float)
signal zone_unlocked(zone_name: String)

# ========================
# UI EVENTS
# ========================
signal hud_updated
signal notification_shown(message: String, type: String)
signal screen_shake_requested(intensity: float, duration: float)
signal camera_focus_requested(target: Node2D, duration: float)

# ========================
# AUDIO EVENTS
# ========================
signal sfx_requested(sound_name: String)
signal music_requested(track_name: String, fade_duration: float)
signal music_stopped(fade_duration: float)
signal audio_volume_changed(bus_name: String, volume: float)

# ========================
# DATA EVENTS
# ========================
signal data_collected(data_type: String, amount: int)
signal save_requested
signal load_requested
signal settings_changed(settings: Dictionary)

# ========================
# DEBUG EVENTS
# ========================
signal debug_command_executed(command: String, result: Variant)
signal debug_overlay_toggled(visible: bool)

# ========================
# HELPER FUNCTIONS
# ========================

## Emit virus XP event with validation
func emit_virus_xp_gained(amount: int, total_xp: int) -> void:
	if amount <= 0:
		push_warning("EventBus: Attempting to add negative or zero XP")
		return
	virus_xp_gained.emit(amount, total_xp)

## Emit notification with type validation
func emit_notification(message: String, type: String = "info") -> void:
	if message.is_empty():
		push_warning("EventBus: Empty notification message")
		return
	
	var valid_types := ["info", "warning", "error", "success"]
	if type not in valid_types:
		push_warning("EventBus: Invalid notification type: %s" % type)
		type = "info"
	
	notification_shown.emit(message, type)

## Emit screen shake with validation
func emit_screen_shake(intensity: float = 1.0, duration: float = 0.3) -> void:
	intensity = clamp(intensity, 0.0, 10.0)
	duration = clamp(duration, 0.0, 5.0)
	screen_shake_requested.emit(intensity, duration)

## Emit SFX request with validation
func emit_sfx(sound_name: String, volume: float = 1.0) -> void:
	if sound_name.is_empty():
		push_warning("EventBus: Empty sound name")
		return
	volume = clamp(volume, 0.0, 1.0)
	sfx_requested.emit(sound_name, volume)

## Emit music change request
func emit_music(track_name: String, fade_duration: float = 0.5) -> void:
	fade_duration = max(0.0, fade_duration)
	music_requested.emit(track_name, fade_duration)

## Stop current music
func emit_stop_music(fade_duration: float = 0.5) -> void:
	fade_duration = max(0.0, fade_duration)
	music_stopped.emit(fade_duration)