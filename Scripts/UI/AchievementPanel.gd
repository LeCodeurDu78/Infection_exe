extends Control

## Achievement Panel UI
## Shows all achievements with progress and unlock status

# ========================
# NODES
# ========================
@onready var scroll_container: ScrollContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer
@onready var achievements_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/AchievementsList
@onready var stats_label: Label = $Panel/MarginContainer/VBoxContainer/StatsContainer/StatsLabel
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/Header/CloseButton

# ========================
# ACHIEVEMENT ITEM SCENE
# ========================
const ACHIEVEMENT_ITEM_SCENE = preload("res://Scenes/UI/AchievementItem.tscn")

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	refresh()

# ========================
# DISPLAY
# ========================
func show_panel() -> void:
	"""Show the achievement panel"""
	visible = true
	refresh()

func hide_panel() -> void:
	"""Hide the achievement panel"""
	visible = false
	if get_parent().has_node("Container"):
		get_parent().get_node("Container").visible = true

func refresh() -> void:
	"""Refresh achievements list"""
	# Clear existing items
	for child in achievements_list.get_children():
		child.queue_free()
	
	# Add achievement items
	var all_achievements := AchievementManager.get_all_achievements()
	
	for achievement in all_achievements:
		# Skip secret achievements if not unlocked
		if achievement.secret and not achievement.unlocked:
			continue
		
		var item = ACHIEVEMENT_ITEM_SCENE.instantiate()
		achievements_list.add_child(item)
		item.setup(achievement)
	
	# Update stats
	_update_stats()

func _update_stats() -> void:
	"""Update statistics display"""
	var stats := AchievementManager.get_stats()
	stats_label.text = "%d / %d (%d%%)" % [
		stats.unlocked,
		stats.total,
		int(stats.completion_percent)
	]

# ========================
# SIGNALS
# ========================
func _on_close_pressed() -> void:
	hide_panel()
