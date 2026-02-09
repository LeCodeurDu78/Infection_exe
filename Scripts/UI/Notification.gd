extends PanelContainer

## Individual Notification Toast
## Displays a single notification message

# ========================
# COLORS BY TYPE
# ========================
const TYPE_COLORS := {
	"info": Color(0.2, 0.6, 1.0, 1.0),      # Blue
	"success": Color(0.224, 1, 0.078, 1.0), # Green #39FF14
	"warning": Color(1.0, 0.6, 0.0, 1.0),   # Orange
	"error": Color(1.0, 0.2, 0.2, 1.0),     # Red
}

const TYPE_ICONS := {
	"info": "ℹ️",
	"success": "✅",
	"warning": "⚠️",
	"error": "❌",
}

# ========================
# SETUP
# ========================
func setup(message: String, type: String = "info") -> void:
	"""Configure the notification with message and type"""
	
	# Validate type
	if type not in TYPE_COLORS:
		type = "info"
	
	# Set message
	$MarginContainer/HBoxContainer/VBoxContainer/Message.text = message
	
	# Set icon
	$MarginContainer/HBoxContainer/Icon.text = TYPE_ICONS[type]
	
	# Set border color
	var style_box: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	style_box.border_color = TYPE_COLORS[type]
	add_theme_stylebox_override("panel", style_box)
	
	# Adjust size to content
	await get_tree().process_frame
	custom_minimum_size.y = size.y
