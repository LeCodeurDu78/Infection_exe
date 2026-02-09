extends Node

## Audio Manager - Example System Using EventBus
## Demonstrates how to create a system that listens to EventBus events
## This is a template/example - adapt it to your needs!

# ========================
# AUDIO PLAYERS
# ========================
@onready var music_player := AudioStreamPlayer.new()
@onready var sfx_player := AudioStreamPlayer.new()

# ========================
# AUDIO LIBRARIES
# ========================
var sfx_library := {
	# Infection sounds
	"infection_start": preload("res://Assets/Sounds/SFX/infection_start.wav"),
	"infection_complete": preload("res://Assets/Sounds/SFX/infection_complete.wav"),
	
	# UI sounds
	"level_up": preload("res://Assets/Sounds/SFX/level_up.wav"),
	"mutation_unlock": preload("res://Assets/Sounds/SFX/mutation_unlock.wav"),
	"button_click": preload("res://Assets/Sounds/SFX/button_click.wav"),
	
	# Combat sounds
	"virus_detected": preload("res://Assets/Sounds/SFX/virus_detected.wav"),
	"scan_launch": preload("res://Assets/Sounds/SFX/scan_launch.wav"),
	"virus_hit": preload("res://Assets/Sounds/SFX/virus_hit.wav"),
}

var music_library := {
	"menu": preload("res://Assets/Sounds/Musics/menu_theme.mp3"),
	"gameplay": preload("res://Assets/Sounds/Musics/gameplay_theme.mp3"),
	"boss": preload("res://Assets/Sounds/Musics/boss_theme.mp3"),
}

# ========================
# STATE
# ========================
var current_music_track := ""
var is_music_playing := false

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	# Setup audio players
	add_child(music_player)
	add_child(sfx_player)
	
	music_player.bus = "Music"
	sfx_player.bus = "SFX"
	
	# Connect to EventBus - This is the key part!
	_connect_events()
	
func _connect_events() -> void:
	"""Connect to all relevant EventBus signals"""
	
	# Infection events
	EventBus.infection_started.connect(_on_infection_started)
	EventBus.infection_completed.connect(_on_infection_completed)
	
	# Virus events
	EventBus.virus_leveled_up.connect(_on_virus_level_up)
	EventBus.virus_damaged.connect(_on_virus_damaged)
	EventBus.virus_destroyed.connect(_on_virus_destroyed)
	
	# Mutation events
	EventBus.mutation_unlocked.connect(_on_mutation_unlocked)
	EventBus.mutation_activated.connect(_on_mutation_activated)
	EventBus.mutation_ability_used.connect(_on_mutation_used)
	
	# Antivirus events
	EventBus.antivirus_detected_virus.connect(_on_virus_detected)
	EventBus.scan_launched.connect(_on_scan_launched)
	
	# Threat level events
	EventBus.threat_level_changed.connect(_on_threat_level_changed)
	
	# Game state events
	EventBus.start_menu.connect(_on_start_menu)
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_won.connect(_on_game_won)
	EventBus.game_lost.connect(_on_game_lost)
	
	# Direct audio requests (from EventBus helper functions)
	EventBus.sfx_requested.connect(_on_sfx_requested)
	EventBus.music_requested.connect(_on_music_requested)
	EventBus.music_stopped.connect(_on_music_stopped)

# ========================
# EVENT HANDLERS
# ========================

# Infection events
func _on_infection_started(_target: Node, _points: int) -> void:
	play_sfx("infection_start")

func _on_infection_completed(_position: Vector2, _points: int) -> void:
	play_sfx("infection_complete")

# Virus events
func _on_virus_level_up(_new_level: int) -> void:
	play_sfx("level_up")

func _on_virus_damaged(_amount: int, _remaining_health: int) -> void:
	play_sfx("virus_hit")

func _on_virus_destroyed(_virus: Node2D) -> void:
	# Play dramatic death sound
	play_sfx("virus_hit")

# Mutation events
func _on_mutation_unlocked(_mutation: Mutation) -> void:
	play_sfx("mutation_unlock")

func _on_mutation_activated(_mutation: Mutation) -> void:
	play_sfx("button_click")

func _on_mutation_used(_mutation_name: String) -> void:
	# Could play specific sounds based on mutation type
	play_sfx("button_click")

# Antivirus events
func _on_virus_detected(_antivirus: Node2D, _virus: Node2D) -> void:
	play_sfx("virus_detected")

func _on_scan_launched(_position: Vector2, _scale: Vector2) -> void:
	play_sfx("scan_launch")

# Threat level events
func _on_threat_level_changed(_old_level: int, new_level: int) -> void:
	if new_level == GameManager.ThreatLevel.CRITICAL:
		# Switch to more intense music
		play_music("boss")
	elif new_level == GameManager.ThreatLevel.LOW:
		# Back to normal music
		play_music("gameplay")

# Game state events
func _on_start_menu() -> void:
	play_music("menu")

func _on_game_started() -> void:
	play_music("gameplay")

func _on_game_won(_infection_percent: float, _time: float) -> void:
	stop_music(1.0)
	# Could play victory jingle

func _on_game_lost(_reason: String) -> void:
	stop_music(1.0)
	# Could play defeat sound

# Direct audio requests
func _on_sfx_requested(sound_name: String) -> void:
	play_sfx(sound_name)

func _on_music_requested(track_name: String, fade_duration: float) -> void:
	play_music(track_name, fade_duration)

func _on_music_stopped(fade_duration: float) -> void:
	stop_music(fade_duration)

# ========================
# AUDIO PLAYBACK
# ========================
func play_sfx(sound_name: String) -> void:
	"""Play a sound effect"""
	if sound_name not in sfx_library:
		push_warning("AudioManager: SFX '%s' not found" % sound_name)
		return
	
	var sound: Resource = sfx_library[sound_name]
	sfx_player.stream = sound
	sfx_player.play()

func play_music(track_name: String, fade_duration: float = 1.0) -> void:
	"""Play background music with optional fade"""
	if track_name not in music_library:
		push_warning("AudioManager: Music '%s' not found" % track_name)
		return
	
	# Don't restart if already playing
	if current_music_track == track_name and is_music_playing:
		return
	
	var music: Resource = music_library[track_name]
	
	# Fade out current music
	if is_music_playing:
		await _fade_out_music(fade_duration)
	
	# Play new music
	music_player.stream = music
	music_player.play()
	current_music_track = track_name
	is_music_playing = true
	
	# Fade in
	await _fade_in_music(fade_duration)

func stop_music(fade_duration: float = 0.5) -> void:
	"""Stop music with fade out"""
	if not is_music_playing:
		return
	
	await _fade_out_music(fade_duration)
	music_player.stop()
	is_music_playing = false
	current_music_track = ""

# ========================
# HELPERS
# ========================
func _fade_out_music(duration: float) -> void:
	"""Fade out current music"""
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, duration)
	await tween.finished

func _fade_in_music(duration: float) -> void:
	"""Fade in current music"""
	var last_volume := music_player.volume_db
	music_player.volume_db = -80.0
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, duration)
	await tween.finished
	music_player.volume_db = last_volume # Restore original volume after fade in

# ========================
# UTILITY
# ========================
func set_master_volume(volume: float) -> void:
	"""Set master volume (0.0 - 1.0)"""
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(volume)
	)

func set_music_volume(volume: float) -> void:
	"""Set music volume (0.0 - 1.0)"""
	music_player.volume_db = linear_to_db(volume)

func set_sfx_volume(volume: float) -> void:
	"""Set SFX volume (0.0 - 1.0)"""
	sfx_player.volume_db = linear_to_db(volume)