extends PanelContainer

## Zone Button
## Shows zone info and allows selection

# ========================
# SIGNALS
# ========================
signal zone_selected(zone_id: String)

# ========================
# NODES
# ========================
@onready var zone_name: Label = $MarginContainer/VBoxContainer/Header/ZoneName
@onready var difficulty: Label = $MarginContainer/VBoxContainer/Header/Difficulty
@onready var description: Label = $MarginContainer/VBoxContainer/Description
@onready var stats: Label = $MarginContainer/VBoxContainer/Stats
@onready var select_button: Button = $MarginContainer/VBoxContainer/SelectButton
@onready var status_label: Label = $MarginContainer/VBoxContainer/Header/Status

# ========================
# DATA
# ========================
var zone_data = null

# ========================
# SETUP
# ========================
func setup(zone) -> void:
	"""Setup zone button with zone data"""
	zone_data = zone
	
	# Name
	zone_name.text = zone.name
	
	# Difficulty
	var stars := "⭐".repeat(zone.difficulty)
	difficulty.text = stars
	
	# Description
	description.text = zone.description
	
	# Stats
	var stats_text := "Infections requises: %d\n" % zone.required_infections
	stats_text += "Multiplicateur XP: x%.1f\n" % zone.xp_multiplier
	stats_text += "Menace: x%.1f" % zone.threat_multiplier
	stats.text = stats_text
	
	# Status and button
	if zone.completed:
		status_label.text = "✅ Complétée"
		select_button.text = "Rejouer"
		select_button.disabled = false
		modulate = Color(0.8, 1, 0.8, 1)
	elif zone.unlocked:
		status_label.text = "🔓 Disponible"
		select_button.text = "Commencer"
		select_button.disabled = false
		modulate = Color(1, 1, 1, 1)
	else:
		status_label.text = "🔒 Verrouillée"
		select_button.text = "Verrouillée"
		select_button.disabled = true
		modulate = Color(0.5, 0.5, 0.5, 1)
	
	# Connect button
	if not select_button.pressed.is_connected(_on_select_pressed):
		select_button.pressed.connect(_on_select_pressed)
	
	# Style
	var style_box: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	if zone.unlocked:
		style_box.border_color = Color(0.224, 1, 0.078, 0.8)
	else:
		style_box.border_color = Color(0.5, 0.5, 0.5, 0.3)
	add_theme_stylebox_override("panel", style_box)

# ========================
# SIGNALS
# ========================
func _on_select_pressed() -> void:
	"""Select button clicked"""
	if zone_data:
		zone_selected.emit(zone_data.id)
