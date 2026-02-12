extends PanelContainer

## Individual Achievement Item
## Shows one achievement with its unlock status and progress

# ========================
# NODES
# ========================
@onready var icon_label: Label = $MarginContainer/HBoxContainer/Icon
@onready var info_container: VBoxContainer = $MarginContainer/HBoxContainer/InfoContainer
@onready var name_label: Label = $MarginContainer/HBoxContainer/InfoContainer/Name
@onready var desc_label: Label = $MarginContainer/HBoxContainer/InfoContainer/Description
@onready var progress_bar: ProgressBar = $MarginContainer/HBoxContainer/InfoContainer/ProgressBar
@onready var status_label: Label = $MarginContainer/HBoxContainer/Status

# ========================
# SETUP
# ========================
func setup(achievement) -> void:
	"""Setup the achievement item display"""
	
	# Icon
	icon_label.text = achievement.icon
	
	# Name
	name_label.text = achievement.name
	
	# Description
	if achievement.secret and not achievement.unlocked:
		desc_label.text = "Achievement secret - Non débloqué"
	else:
		desc_label.text = achievement.description
	
	# Progress bar
	if achievement.target > 1:
		progress_bar.visible = true
		progress_bar.max_value = achievement.target
		progress_bar.value = achievement.progress
	else:
		progress_bar.visible = false
	
	# Status
	if achievement.unlocked:
		status_label.text = "✅"
		modulate = Color(1, 1, 1, 1)
		
		# Show unlock date if available
		if achievement.unlock_time > 0:
			var datetime := Time.get_datetime_dict_from_unix_time(achievement.unlock_time)
			var date_str := "%02d/%02d/%04d" % [datetime.day, datetime.month, datetime.year]
			desc_label.text += "\n🕐 Débloqué le: " + date_str
	else:
		status_label.text = "🔒"
		modulate = Color(0.6, 0.6, 0.6, 1)
	
	# Style based on unlock status
	var style_box: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	if achievement.unlocked:
		style_box.border_color = Color(0.224, 1, 0.078, 1)  # Green
	else:
		style_box.border_color = Color(0.5, 0.5, 0.5, 0.5)  # Gray
	add_theme_stylebox_override("panel", style_box)
