extends Control

## Heads-Up Display (HUD)
## Shows XP, threat level, and mutation cooldowns

# ========================
# NODE REFERENCES
# ========================
@onready var xp_label: Label = $Infection/XPLabel
@onready var threat_label: Label = $Infection/ThreatLabel
@onready var cooldown_container: Control = $MutationsCooldowns

# ========================
# CONSTANTS
# ========================
const THREAT_COLORS := {
	GameManager.ThreatLevel.LOW: Color.GREEN,
	GameManager.ThreatLevel.MEDIUM: Color.ORANGE,
	GameManager.ThreatLevel.CRITICAL: Color.RED
}

const THREAT_TEXTS := {
	GameManager.ThreatLevel.LOW: "Menace : FAIBLE",
	GameManager.ThreatLevel.MEDIUM: "Menace : MOYENNE",
	GameManager.ThreatLevel.CRITICAL: "Menace : CRITIQUE"
}

# ========================
# REFERENCES
# ========================
var mutation_manager: MutationManager = null

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	add_to_group("hud")
	call_deferred("_find_mutation_manager")
	EventBus.game_started.emit()

func _find_mutation_manager() -> void:
	"""Find mutation manager in scene"""
	if is_instance_valid(GameManager.virus_node):
		mutation_manager = GameManager.virus_node.get_node_or_null("MutationManager")

func _process(_delta: float) -> void:
	_update_xp_display()
	_update_threat_display()
	_update_cooldown_displays()

# ========================
# XP DISPLAY
# ========================
func _update_xp_display() -> void:
	"""Update XP label"""
	xp_label.text = "XP : " + GameManager.get_virus_xp_text()

# ========================
# THREAT DISPLAY
# ========================
func _update_threat_display() -> void:
	"""Update threat level label and color"""
	var threat_level := GameManager.get_threat_level()
	threat_label.text = THREAT_TEXTS.get(threat_level, "Menace : INCONNUE")
	threat_label.modulate = THREAT_COLORS.get(threat_level, Color.WHITE)

# ========================
# COOLDOWN DISPLAY
# ========================
func _update_cooldown_displays() -> void:
	"""Update mutation cooldown progress bars"""
	# Hide all cooldown displays initially
	_hide_all_cooldowns()
	
	if not mutation_manager:
		return
	
	var cooldown_info := mutation_manager.get_cooldown_info()
	var index := 0
	
	for keybind in cooldown_info:
		index += 1
		var progress_bar := _get_cooldown_bar(index)
		if not progress_bar:
			continue
		
		var info: Dictionary = cooldown_info[keybind]
		var current: float = info.get("current", 0.0)
		var maximum: float = info.get("max", 1.0)
		
		if current > 0.0:
			_show_cooldown(progress_bar, current, maximum)

func _hide_all_cooldowns() -> void:
	"""Hide all cooldown progress bars"""
	for i in range(1, 7):  # Support up to 6 mutations
		var bar := _get_cooldown_bar(i)
		if bar:
			bar.modulate.a = 0.0

func _get_cooldown_bar(index: int) -> TextureProgressBar:
	"""Get cooldown progress bar by index"""
	var node_name := "MutationCooldown%d" % index
	return cooldown_container.get_node_or_null(node_name)

func _show_cooldown(bar: TextureProgressBar, current: float, maximum: float) -> void:
	"""Display cooldown on progress bar"""
	bar.value = (current / maximum) * 100.0
	bar.modulate.a = 1.0
